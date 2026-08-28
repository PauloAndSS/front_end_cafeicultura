import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import 'mock_http.dart';

Funcionario funcionarioValido() => Funcionario(
      pessoa: PessoaFisica(nome: 'Fulano', cpf: CPF.criar('529.982.247-25')),
    );

Cliente clienteValido() => Cliente(
      pessoa: PessoaFisica(nome: 'Ciclano', cpf: CPF.criar('529.982.247-25')),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  setUp(() => BaseService.sessionCookie = null);

  group('sessao', () {
    test('autenticar com sucesso guarda o cookie e devolve a sessao', () async {
      final resultado = await comRespostaFixa(
        () => ServicesAuth().autenticar(
          LoginRequestDTO(tipoEntrada: 'email', entrada: 'a@b.c', senha: '123'),
        ),
        respostaJson(
          {
            'data': {
              'mensagem': 'Login efetuado',
              'dadosSessao': {
                'id': 7,
                'nome': 'Heitor',
                'idsPropriedades': [1, 2],
              },
            }
          },
          200,
          headers: {'set-cookie': 'sid=abc123; Path=/; HttpOnly'},
        ),
      );

      expect(resultado.mensagem, 'Login efetuado');
      expect(resultado.sessaoAtiva?.idUsuario, 7);
      expect(BaseService.sessionCookie, 'sid=abc123');
    });

    test('sair com sucesso limpa o cookie estatico', () async {
      BaseService.sessionCookie = 'sid=abc123';

      await comRespostaFixa(
        () => ServicesAuth().sair(),
        respostaJson({'mensagem': 'ok'}, 200),
      );

      expect(BaseService.sessionCookie, isNull);
    });

    test('o cookie guardado viaja em toda requisicao seguinte', () async {
      BaseService.sessionCookie = 'sid=abc123';
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesPropriedade().buscarPorProprietario(),
        respostaJson({'data': []}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.headers['Cookie'], 'sid=abc123');
    });
  });

  group('mensagem do backend sobrevive (o rethrow)', () {
    test('erro de autenticacao mostra o texto do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesAuth().autenticar(
            LoginRequestDTO(
              tipoEntrada: 'email',
              entrada: 'a@b.c',
              senha: 'errada',
            ),
          ),
          respostaJson({'error': 'Senha invalida'}, 401),
        ),
      );

      expect(erro.mensagem, contains('Senha invalida'));
      expect(erro.mensagem, isNot(contains('Falha na comunicação')));
    });

    test('lista de erros de validacao vira ApiValidationException', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesPropriedade().atualizarNome(1, ''),
          respostaJson({
            'erros': [
              {'msg': 'Nome é obrigatório'},
              {'msg': 'Nome muito curto'},
            ]
          }, 422),
        ),
      );

      expect(erro, isA<ApiValidationException>());
      expect((erro as ApiValidationException).mensagens, [
        'Erro ao atualizar nome da propriedade.',
        '• Nome é obrigatório',
        '• Nome muito curto',
      ]);
    });

    test('falha de rede vira a mensagem padrao com a acao do metodo', () async {
      final erro = await erroDe(
        () => comFalhaDeRede(
          () => ServicesPropriedade().buscarPorProprietario(),
        ),
      );

      expect(
        erro.mensagem,
        'Falha na comunicação ao buscar propriedades. Tente novamente mais tarde.',
      );
    });
  });

  group('errosPorStatus', () {
    test('409 no cadastro de insumo usa a mensagem propria', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesInsumo().cadastrar(
            Insumo(descricao: 'Adubo', medida: MedidaInsumo.quilograma),
            1,
          ),
          respostaJson({'error': 'conflito'}, 409),
        ),
      );

      expect(erro.mensagem, 'Já existe um insumo com essa descrição.');
    });

    test('403 ao excluir talhao explica o impedimento', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesTalhao().excluir(3),
          respostaJson({'error': 'proibido'}, 403),
        ),
      );

      expect(
        erro.mensagem,
        'Talhão não pode ser excluído pois há atividades cadastradas nele.',
      );
    });

    test('403 ao excluir propriedade explica o impedimento', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesPropriedade().excluir(3),
          respostaJson({'error': 'proibido'}, 403),
        ),
      );

      expect(erro.mensagem, contains('possui talhões e/ou safras'));
    });

    test('404 do proprietario vence o isEmptyList', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesProprietario().buscarPorId(9),
          respostaJson({'mensagem': 'nada aqui'}, 404),
        ),
      );

      expect(erro.mensagem, 'Proprietário não encontrado.');
    });

    test('o rotulo do papel entra na mensagem de impedimento', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesFuncionario().excluir(4),
          respostaJson({'error': 'proibido'}, 403),
        ),
      );

      expect(
        erro.mensagem,
        'Funcionário possui atividades e/ou despesas cadastradas '
        'e não pode ser excluído.',
      );
    });

    test('papel com conflitoDeCadastro traduz o 409', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesFuncionario().cadastrar(funcionarioValido()),
          respostaJson({'error': 'duplicado'}, 409),
        ),
      );

      expect(erro.mensagem, 'CPF já cadastrado no sistema.');
    });

    test('papel sem conflitoDeCadastro deixa o 409 cair no backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesCliente().cadastrar(clienteValido()),
          respostaJson({'error': 'algo do backend'}, 409),
        ),
      );

      expect(erro.mensagem, contains('algo do backend'));
      expect(erro.mensagem, isNot(contains('CPF já cadastrado')));
    });
  });

  group('aoListaVazia — 404 com corpo JSON', () {
    test('proprietario sem propriedades recebe lista vazia', () async {
      final propriedades = await comRespostaFixa(
        () => ServicesPropriedade().buscarPorProprietario(),
        respostaJson({'mensagem': 'Nenhuma propriedade cadastrada'}, 404),
      );

      expect(propriedades, isEmpty);
    });

    test('propriedade sem talhoes recebe lista vazia', () async {
      final talhoes = await comRespostaFixa(
        () => ServicesTalhao().buscarPorPropriedade(1),
        respostaJson({'mensagem': 'Nenhum talhão cadastrado'}, 404),
      );

      expect(talhoes, isEmpty);
    });

    test('propriedade sem safras recebe lista vazia', () async {
      final safras = await comRespostaFixa(
        () => ServicesSafra().buscarPorPropriedade(1),
        respostaJson({'mensagem': 'Nenhuma safra cadastrada'}, 404),
      );

      expect(safras, isEmpty);
    });

    test('pessoas sem cadastro devolvem pagina vazia que encerra a rolagem',
        () async {
      final pagina = await comRespostaFixa(
        () => ServicesPessoa().buscarPorProprietario(pagina: 3),
        respostaJson({'mensagem': 'Nenhuma pessoa'}, 404),
      );

      expect(pagina.data, isEmpty);
      expect(pagina.total, 0);
      expect(pagina.pagina, 3);
      expect(pagina.totalPaginas, 3);
    });

    test('metodo sem aoListaVazia trata 404 como erro de verdade', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesPropriedade().buscarPorId(1),
          respostaJson({'mensagem': 'não existe'}, 404),
        ),
      );

      expect(erro.mensagem, contains('Erro ao buscar propriedade.'));
    });

    test('404 sem corpo JSON continua sendo erro', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesTalhao().buscarPorPropriedade(1),
          http.Response.bytes(utf8.encode('<html>rota errada</html>'), 404),
        ),
      );

      expect(erro.mensagem, contains('Erro ao buscar talhões da propriedade.'));
    });
  });

  group('aoListaVazia — ausencia de registros vinda como erro', () {
    test('relatorio de safra sem eventos devolve lista vazia', () async {
      final eventos = await comRespostaFixa(
        () => ServicesSafra().buscarRelatorio(idPropriedade: 1, idSafra: 2),
        respostaJson({'error': 'A safra não possui eventos cadastrados'}, 400),
      );

      expect(eventos, isEmpty);
    });

    test('relatorio de talhao sem eventos devolve lista vazia', () async {
      final eventos = await comRespostaFixa(
        () => ServicesSafra().buscarRelatorioDoTalhao(
          idPropriedade: 1,
          idSafra: 2,
          idTalhao: 3,
        ),
        respostaJson({'error': 'O talhão não possui eventos registrados'}, 400),
      );

      expect(eventos, isEmpty);
    });

    test('erro de verdade no relatorio continua chegando a tela', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesSafra().buscarRelatorio(idPropriedade: 1, idSafra: 2),
          respostaJson({'error': 'Safra não pertence ao proprietário'}, 403),
        ),
      );

      expect(erro.mensagem, contains('Safra não pertence ao proprietário'));
    });
  });

  group('rota e verbo preservados na migracao', () {
    test('buscar talhoes usa GET na rota paginada do recurso', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesTalhao().buscarPorPropriedade(7, pagina: 2),
        respostaJson({'talhoes': []}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'GET');
      expect(enviada.url.path, endsWith('/talhoes/propriedade/todos/7'));
      expect(enviada.url.queryParameters, {'pagina': '2', 'limite': '10'});
    });

    test('excluir propriedade usa DELETE', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesPropriedade().excluir(5),
        respostaJson({'mensagem': 'ok'}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'DELETE');
      expect(enviada.url.path, endsWith('/propriedades/5'));
    });

    test('atualizar salario usa PUT com o corpo esperado', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesFuncionario().atualizarSalario(4, 1500.50),
        respostaJson({'mensagem': 'ok'}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'PUT');
      expect(enviada.url.path, endsWith('/funcionarios/4/salario'));
      expect(jsonDecode(enviada.body), {'salario': 1500.50});
    });

    test('atualizar nome da propriedade usa PATCH', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesPropriedade().atualizarNome(5, 'Sítio Novo'),
        respostaJson({'mensagem': 'ok'}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'PATCH');
      expect(enviada.url.path, endsWith('/propriedades/5/nome'));
      expect(jsonDecode(enviada.body), {'nome': 'Sítio Novo'});
    });
  });
}
