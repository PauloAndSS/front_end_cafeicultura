import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/compra_insumo.dart';
import 'package:http/http.dart' as http;

class ServicesCompraInsumo extends BaseService {
  @override
  String get recurso => 'comprasinsumos';

  Future<bool> cadastrar(CompraDeInsumos compra) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(compra.toJson()),
      ),
      aoSucesso: (_) => true,
      resultadosPorStatus: {if (compra.conflitaPorDescricao) 409: () => false},
      erroMsg: 'Erro ao registrar a compra do insumo.',
      acao: 'registrar a compra do insumo',
    );
  }
}
