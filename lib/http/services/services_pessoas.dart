import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
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
      // `totalPaginas` igual à página pedida encerra a rolagem de quem consome.
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

  TipoPapel get tipoPapel;

  String get rotulo => tipoPapel.rotulo;

  String? get conflitoDeCadastro => null;

  String get impedimentoDeExclusao =>
      '${tipoPapel.titulo} possui atividades e/ou despesas cadastradas '
      'e não pode ser excluído.';

  /// Listagem paginada da própria rota do papel (`/meeiros`, `/clientes`, ...).
  ///
  /// Desserializa com `montar`, e não com `PapelPessoaFactory`: a rota já diz
  /// qual é o papel, e o payload dela **não traz o campo `papel`** — a factory
  /// lançaria em todo item.
  Future<ResultadoPaginadoDTO<T>> listar({int pagina = 1, int limite = 20}) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('', {'pagina': '$pagina', 'limite': '$limite'}),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => ResultadoPaginadoDTO<T>.deEnvelopeDeDados(
        extrairDadosPaginados(resposta.bodyBytes),
        montar,
        paginaSolicitada: pagina,
        limiteSolicitado: limite,
      ),
      aoListaVazia: () => ResultadoPaginadoDTO<T>(
        data: const [],
        total: 0,
        pagina: pagina,
        totalPaginas: pagina,
      ),
      erroMsg: 'Erro ao buscar a lista de ${tipoPapel.rotuloPlural}.',
      acao: 'buscar os ${tipoPapel.rotuloPlural}',
    );
  }

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
      errosPorStatus: {404: '${tipoPapel.titulo} não encontrado.'},
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
}

ServicePapelPessoa<PapelPessoa> servicoDoPapel(TipoPapel papel) =>
    switch (papel) {
      TipoPapel.funcionario => ServicesFuncionario(),
      TipoPapel.meeiro => ServicesMeeiro(),
      TipoPapel.fornecedor => ServicesFornecedor(),
      TipoPapel.prestador => ServicesPrestadorDeServico(),
      TipoPapel.cliente => ServicesCliente(),
    };

class ServicesFornecedor extends ServicePapelPessoa<Fornecedor> {
  @override
  String get recurso => 'fornecedores';

  @override
  TipoPapel get tipoPapel => TipoPapel.fornecedor;

  @override
  Fornecedor Function(Map<String, dynamic>) get montar => Fornecedor.fromJson;
}

class ServicesFuncionario extends ServicePapelPessoa<Funcionario> {
  @override
  String get recurso => 'funcionarios';

  @override
  TipoPapel get tipoPapel => TipoPapel.funcionario;

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
  TipoPapel get tipoPapel => TipoPapel.cliente;

  @override
  Cliente Function(Map<String, dynamic>) get montar => Cliente.fromJson;

}

class ServicesMeeiro extends ServicePapelPessoa<Meeiro> {
  @override
  String get recurso => 'meeiros';

  @override
  TipoPapel get tipoPapel => TipoPapel.meeiro;

  @override
  Meeiro Function(Map<String, dynamic>) get montar => Meeiro.fromJson;

  @override
  String get conflitoDeCadastro => 'CPF já cadastrado no sistema.';

}

class ServicesPrestadorDeServico extends ServicePapelPessoa<PrestadorDeServico> {
  @override
  String get recurso => 'prestadores';

  @override
  TipoPapel get tipoPapel => TipoPapel.prestador;

  @override
  PrestadorDeServico Function(Map<String, dynamic>) get montar =>
      PrestadorDeServico.fromJson;

}
