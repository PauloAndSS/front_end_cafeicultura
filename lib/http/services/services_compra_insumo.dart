import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:http/http.dart' as http;

class ServicesCompraInsumo extends BaseService {
  @override
  String get recurso => 'comprasinsumos';

  Future<Insumo?> cadastrar(CompraDeInsumos compra) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(compra.toJson()),
      ),
      aoSucesso: (resposta) => _lerInsumoDaResposta(resposta.bodyBytes),
      errosPorStatus: {409: ?compra.mensagemDeConflito},
      erroMsg: 'Erro ao registrar a compra do insumo.',
      acao: 'registrar a compra do insumo',
    );
  }

  Insumo? _lerInsumoDaResposta(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) return null;

    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! Map<String, dynamic>) return null;

    final aninhado = dados['insumo'];
    final bruto = aninhado is Map<String, dynamic> ? aninhado : dados;

    return bruto['id'] == null ? null : Insumo.fromJson(bruto);
  }
}
