import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesTalhao extends BaseService {
  @override
  String get recurso => 'talhoes';

  static const int limitePorPagina = 10;

  Future<bool> cadastrar(Talhao talhao) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(url, corpo: talhao.toJson()),
      aoSucesso: (_) => true,
      errosPorStatus: {
        409: 'Erro ao cadastrar talhão. Talhão com esse mesmo nome já foi cadastrado e está ativo.',
      },
      erroMsg: 'Erro ao cadastrar talhão.',
      acao: 'cadastrar talhão',
    );
  }

  Future<List<Talhao>> buscarPorPropriedade(
    int idPropriedade, {
    int pagina = 1,
  }) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(
        rota('propriedade/todos/$idPropriedade', {
          'pagina': '$pagina',
          'limite': '$limitePorPagina',
        }),
      ),
      aoSucesso: (resposta) =>
          extrairListaNomeada(resposta.bodyBytes, 'talhoes', Talhao.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar talhões da propriedade.',
      acao: 'buscar talhões',
    );
  }

  Future<List<Variedade>> buscarVariedades() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('variedades')),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Variedade.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar variedades.',
      acao: 'buscar variedades',
    );
  }

  Future<bool> encerrar(int idTalhao, DateTime dataFim) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(
        rota('$idTalhao/encerrar'),
        corpo: {'dataFim': dataParaJson(dataFim)},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao encerrar talhão.',
      acao: 'encerrar talhão',
    );
  }

  Future<bool> editarDataInicio(int idTalhao, DateTime dataInicio) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(
        rota('$idTalhao/data-inicio'),
        corpo: {'dataInicio': dataParaJson(dataInicio)},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao alterar a data de início do talhão.',
      acao: 'alterar a data de início do talhão',
    );
  }

  Future<bool> excluir(int idTalhao) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.delete(rota('$idTalhao')),
      aoSucesso: (_) => true,
      errosPorStatus: {
        403: 'Talhão não pode ser excluído pois há atividades cadastradas nele.',
      },
      erroMsg: 'Erro ao excluir talhão.',
      acao: 'excluir talhão',
    );
  }
}
