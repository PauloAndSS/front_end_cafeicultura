import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/diarista.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';


class ServicesPessoa extends BaseService {
  @override
  String get recurso => 'pessoas';

  Future<ResultadoPaginadoDTO<PapelPessoa>> buscarPorProprietario({
    int pagina = 1,
    int limite = 20,
  }) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(
        rota('', {'pagina': '$pagina', 'limite': '$limite'}),
      ),
      aoSucesso: (resposta) => ResultadoPaginadoDTO<PapelPessoa>.fromJson(
        extrairDadosPaginados(resposta.bodyBytes),
        PapelPessoaFactory.fromJson,
      ),
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

  Future<List<T>> listar() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(url),
      aoSucesso: (resposta) => extrairListaDeDados(resposta.bodyBytes, montar),
      aoListaVazia: () => <T>[],
      erroMsg: 'Erro ao buscar a lista de ${tipoPapel.rotuloPlural}.',
      acao: 'buscar os ${tipoPapel.rotuloPlural}',
    );
  }

  Future<int?> cadastrar(T papel) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(url, corpo: papel.toJson()),
      aoSucesso: (resposta) => _idDoCadastro(resposta.bodyBytes),
      errosPorStatus: {409: ?conflitoDeCadastro},
      erroMsg: 'Erro ao cadastrar $rotulo.',
      acao: 'cadastrar $rotulo',
    );
  }

  int? _idDoCadastro(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) return null;

    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! Map<String, dynamic>) return null;

    final id = dados['id'];

    return id is num ? id.toInt() : int.tryParse('${id ?? ''}');
  }

  Future<T> buscarPorId(int id) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('$id')),
      aoSucesso: (resposta) => extrairObjeto(resposta.bodyBytes, montar),
      errosPorStatus: {404: '${tipoPapel.titulo} não encontrado.'},
      erroMsg: 'Erro ao buscar dados do $rotulo.',
      acao: 'buscar $rotulo',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.delete(rota('$id')),
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
      TipoPapel.diarista => ServicesDiarista(),
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
      requisicao: RequisicaoHttp.put(
        rota('$id/salario'),
        corpo: {'salario': salario},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar salário do funcionário.',
      acao: 'atualizar salário do funcionário',
    );
  }
}

class ServicesDiarista extends ServicePapelPessoa<Diarista> {
  @override
  String get recurso => 'diaristas';

  @override
  TipoPapel get tipoPapel => TipoPapel.diarista;

  @override
  Diarista Function(Map<String, dynamic>) get montar => Diarista.fromJson;

  @override
  String get conflitoDeCadastro => 'CPF já cadastrado no sistema.';
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
