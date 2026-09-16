import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:http/http.dart' as http;

class ServicesDespesa extends BaseService {
  @override
  String get recurso => 'despesas';

  Future<Despesa?> cadastrar(Despesa despesa) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(despesa.toJson()),
      ),
      aoSucesso: (resposta) =>
          extrairObjetoOuNulo(resposta.bodyBytes, Despesa.fromJson),
      erroMsg: 'Erro ao lançar a despesa.',
      acao: 'lançar a despesa',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      enviar: () => http.delete(rota('$id'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao excluir a despesa.',
      acao: 'excluir a despesa',
    );
  }
}
