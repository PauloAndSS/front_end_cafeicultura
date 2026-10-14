import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesCompraInsumo extends BaseService {
  @override
  String get recurso => 'comprasinsumos';

  Future<bool> cadastrar(CompraDeInsumos compra) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(url, corpo: compra.toJson()),
      aoSucesso: (_) => true,
      resultadosPorStatus: {if (compra.conflitaPorDescricao) 409: () => false},
      erroMsg: 'Erro ao registrar a compra do insumo.',
      acao: 'registrar a compra do insumo',
    );
  }
}
