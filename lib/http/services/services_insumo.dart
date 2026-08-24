import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:http/http.dart' as http;

class ServicesInsumo extends BaseService {
  @override
  String get recurso => 'insumos';

  Future<Insumo?> cadastrar(Insumo insumo, int idProprietario) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode({'idProprietario': idProprietario, ...insumo.toJson()}),
      ),
      aoSucesso: (resposta) =>
          extrairObjetoOuNulo(resposta.bodyBytes, Insumo.fromJson),
      errosPorStatus: {409: 'Já existe um insumo com essa descrição.'},
      erroMsg: 'Erro ao cadastrar insumo.',
      acao: 'cadastrar insumo',
    );
  }

  Future<List<Insumo>> buscarTodos() {
    return executarRequisicao(
      enviar: () => http.get(url, headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Insumo.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar os insumos cadastrados.',
      acao: 'buscar os insumos',
    );
  }
}
