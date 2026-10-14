import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesDespesa extends BaseService {
  @override
  String get recurso => 'despesas';

  Future<Despesa?> cadastrar(Despesa despesa) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(url, corpo: despesa.toJson()),
      aoSucesso: (resposta) =>
          extrairObjetoOuNulo(resposta.bodyBytes, Despesa.fromJson),
      erroMsg: 'Erro ao lançar a despesa.',
      acao: 'lançar a despesa',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.delete(rota('$id')),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao excluir a despesa.',
      acao: 'excluir a despesa',
    );
  }
}
