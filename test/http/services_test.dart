import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

http.Response respostaJson(
  Object corpo,
  int status, {
  Map<String, String>? headers,
}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(corpo)),
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      ...?headers,
    },
  );
}

Future<T> comRespostaFixa<T>(
  Future<T> Function() acao,
  http.Response resposta, {
  void Function(http.Request requisicao)? capturar,
}) {
  return http.runWithClient(
    acao,
    () => MockClient((requisicao) async {
      capturar?.call(requisicao);
      return resposta;
    }),
  );
}

Future<T> comFalhaDeRede<T>(Future<T> Function() acao) {
  return http.runWithClient(
    acao,
    () => MockClient((_) async => throw const SocketException('sem rota')),
  );
}

Future<ApiException> erroDe(Future<void> Function() acao) async {
  try {
    await acao();
  } on ApiException catch (e) {
    return e;
  }
  fail('Esperava ApiException, mas a chamada concluiu sem erro.');
}

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

  group('listagem por papel de pessoa', () {
    Map<String, dynamic> envelope(List<Map<String, dynamic>> dados,
            {int pagina = 1, int limite = 20}) =>
        {'pagina': pagina, 'limite': limite, 'dados': dados};

    Map<String, dynamic> meeiro(int id) =>
        {'id': id, 'nome': 'Meeiro $id', 'cpf': '529.982.247-25'};

    test('usa GET na rota do papel com pagina e limite', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesMeeiro().listar(pagina: 2, limite: 20),
        respostaJson(envelope(const [], pagina: 2), 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'GET');
      expect(enviada.url.path, endsWith('/meeiros'));
      expect(enviada.url.queryParameters, {'pagina': '2', 'limite': '20'});
    });

    test('desserializa o envelope de dados com o model do proprio papel',
        () async {
      final resultado = await comRespostaFixa(
        () => ServicesFornecedor().listar(),
        respostaJson(
          envelope([
            {
              'id': 99,
              'razaoSocial': 'AgroInsumos QA LTDA',
              'cnpj': '41802736000160',
            }
          ]),
          200,
        ),
      );

      expect(resultado.data.single.id, 99);
      expect(resultado.data.single.pessoa, isA<PessoaJuridica>());
      expect(resultado.data.single.pessoa.nomeParaExibicao,
          'AgroInsumos QA LTDA');
    });

    test('envelope embrulhado em array e desembrulhado', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(),
        respostaJson([envelope([meeiro(12)])], 200),
      );

      expect(resultado.data.single.id, 12);
    });

    test('pagina cheia deixa a rolagem pedir a proxima', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(limite: 2),
        respostaJson(envelope([meeiro(1), meeiro(2)], limite: 2), 200),
      );

      expect(resultado.pagina, 1);
      expect(resultado.totalPaginas, 2);
    });

    test('pagina incompleta encerra a rolagem', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(pagina: 3, limite: 2),
        respostaJson(envelope([meeiro(9)], pagina: 3, limite: 2), 200),
      );

      expect(resultado.pagina, 3);
      expect(resultado.totalPaginas, 3);
    });

    test('lista vazia nao pede mais nenhuma pagina', () async {
      final resultado = await comRespostaFixa(
        () => ServicesCliente().listar(),
        respostaJson(envelope(const []), 200),
      );

      expect(resultado.data, isEmpty);
      expect(resultado.totalPaginas, resultado.pagina);
    });

    test('totalPaginas do backend vence a inferencia', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(limite: 2),
        respostaJson(
          {...envelope([meeiro(1), meeiro(2)], limite: 2), 'totalPaginas': 7},
          200,
        ),
      );

      expect(resultado.totalPaginas, 7);
    });

    test('total e limite derivam o total de paginas', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(limite: 2),
        respostaJson(
          {...envelope([meeiro(1), meeiro(2)], limite: 2), 'total': 5},
          200,
        ),
      );

      expect(resultado.totalPaginas, 3);
    });

    test('404 com corpo JSON encerra a rolagem na pagina pedida', () async {
      final resultado = await comRespostaFixa(
        () => ServicesMeeiro().listar(pagina: 4),
        respostaJson({'mensagem': 'Nenhum meeiro encontrado'}, 404),
      );

      expect(resultado.data, isEmpty);
      expect(resultado.pagina, 4);
      expect(resultado.totalPaginas, 4);
    });

    test('mensagem de erro nomeia o papel no plural', () async {
      final erro = await erroDe(
        () => comFalhaDeRede(() => ServicesPrestadorDeServico().listar()),
      );

      expect(erro.mensagem, contains('prestadores de serviço'));
    });
  });

  group('confirmar atividade nunca manda data no futuro', () {
    Future<Map<String, dynamic>> corpoDeConfirmar({
      required DateTime dataInicio,
      required DateTime dataFim,
    }) async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesTratoCultural()
            .confirmar(7, dataInicio: dataInicio, dataFim: dataFim),
        respostaJson({'mensagem': 'ok'}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      return jsonDecode(enviada.body) as Map<String, dynamic>;
    }

    test('atividade que termina hoje nao ultrapassa o instante da chamada',
        () async {
      final antes = DateTime.now().toUtc();

      final corpo = await corpoDeConfirmar(
        dataInicio: hoje().subtract(const Duration(days: 3)),
        dataFim: hoje(),
      );

      final depois = DateTime.now().toUtc();
      final dataFim = DateTime.parse(corpo['dataFim'] as String);

      expect(dataFim.isAfter(depois), isFalse);
      expect(
        dataFim.isBefore(
          antes.subtract(margemDeRelogio + const Duration(seconds: 5)),
        ),
        isFalse,
      );
    });

    test('atividade de um dia so mantem dataInicio menor ou igual a dataFim',
        () async {
      final corpo = await corpoDeConfirmar(
        dataInicio: hoje(),
        dataFim: hoje(),
      );

      final dataInicio = DateTime.parse(corpo['dataInicio'] as String);
      final dataFim = DateTime.parse(corpo['dataFim'] as String);

      expect(dataInicio.isAfter(dataFim), isFalse);
    });

    test('dia ja encerrado continua viajando em meio-dia UTC', () async {
      final ontem = hoje().subtract(const Duration(days: 1));

      final corpo = await corpoDeConfirmar(dataInicio: ontem, dataFim: ontem);

      final esperado =
          DateTime.utc(ontem.year, ontem.month, ontem.day, 12).toIso8601String();

      expect(corpo['dataInicio'], esperado);
      expect(corpo['dataFim'], esperado);
    });
  });
}
