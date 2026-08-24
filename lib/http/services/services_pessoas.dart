import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:http/http.dart' as http;


class ServicesPessoa extends BaseService {
  @override
  String get recurso => 'pessoas';

  Future<ResultadoPaginadoDTO<PapelPessoa>> buscarPorProprietario({
    int pagina = 1,
    int limite = 20,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('', {'pagina': '$pagina', 'limite': '$limite'}),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => ResultadoPaginadoDTO<PapelPessoa>.fromJson(
        extrairDadosPaginados(resposta.bodyBytes),
        PapelPessoaFactory.fromJson,
      ),
      // Proprietário sem nenhuma pessoa cadastrada: 404 com corpo JSON.
      // `totalPaginas` igual à página pedida encerra a rolagem infinita de
      // quem consome (`temMaisResponsaveis`).
      aoListaVazia: () => ResultadoPaginadoDTO<PapelPessoa>(
        data: const [],
        total: 0,
        pagina: pagina,
        totalPaginas: pagina,
      ),
      erroMsg: 'Erro ao buscar dados.',
      acao: 'buscar dados das pessoas',
    );
  }
}

abstract class ServicePapelPessoa<T extends PapelPessoa> extends BaseService {
  
  T Function(Map<String, dynamic>) get montar;

  String get rotulo;

  String? get conflitoDeCadastro => null;

  String get impedimentoDeExclusao =>
      '$_rotuloCapitalizado possui atividades e/ou despesas cadastradas '
      'e não pode ser excluído.';

  Future<bool> cadastrar(T papel) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(papel.toJson()),
      ),
      aoSucesso: (_) => true,
      errosPorStatus: {409: ?conflitoDeCadastro},
      erroMsg: 'Erro ao cadastrar $rotulo.',
      acao: 'cadastrar $rotulo',
    );
  }

  Future<T> buscarPorId(int id) {
    return executarRequisicao(
      enviar: () => http.get(rota('$id'), headers: defaultHeaders),
      aoSucesso: (resposta) => extrairObjeto(resposta.bodyBytes, montar),
      errosPorStatus: {404: '$_rotuloCapitalizado não encontrado.'},
      erroMsg: 'Erro ao buscar dados do $rotulo.',
      acao: 'buscar $rotulo',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      enviar: () => http.delete(rota('$id'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      errosPorStatus: {403: impedimentoDeExclusao},
      erroMsg: 'Erro ao excluir $rotulo.',
      acao: 'excluir $rotulo',
    );
  }

  String get _rotuloCapitalizado => capitalizar(rotulo);
}

class ServicesFornecedor extends ServicePapelPessoa<Fornecedor> {
  @override
  String get recurso => 'fornecedores';

  @override
  String get rotulo => 'fornecedor';

  @override
  Fornecedor Function(Map<String, dynamic>) get montar => Fornecedor.fromJson;
}

class ServicesFuncionario extends ServicePapelPessoa<Funcionario> {
  @override
  String get recurso => 'funcionarios';

  @override
  String get rotulo => 'funcionário';

  @override
  Funcionario Function(Map<String, dynamic>) get montar => Funcionario.fromJson;
  @override
  String get conflitoDeCadastro => 'CPF já cadastrado no sistema.';


  Future<bool> atualizarSalario(int id, double salario) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/salario'),
        headers: defaultHeaders,
        body: jsonEncode({'salario': salario}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar salário do funcionário.',
      acao: 'atualizar salário do funcionário',
    );
  }
}

class ServicesCliente extends ServicePapelPessoa<Cliente> {
  @override
  String get recurso => 'clientes';

  @override
  String get rotulo => 'cliente';

  @override
  Cliente Function(Map<String, dynamic>) get montar => Cliente.fromJson;

}

class ServicesMeeiro extends ServicePapelPessoa<Meeiro> {
  @override
  String get recurso => 'meeiros';

  @override
  String get rotulo => 'meeiro';

  @override
  Meeiro Function(Map<String, dynamic>) get montar => Meeiro.fromJson;

  @override
  String get conflitoDeCadastro => 'CPF já cadastrado no sistema.';

}

class ServicesPrestadorDeServico extends ServicePapelPessoa<PrestadorDeServico> {
  @override
  String get recurso => 'prestadores';

  @override
  String get rotulo => 'prestador de serviço';

  @override
  PrestadorDeServico Function(Map<String, dynamic>) get montar =>
      PrestadorDeServico.fromJson;

}
