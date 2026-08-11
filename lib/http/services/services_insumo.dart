import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:http/http.dart' as http;

class ServicesInsumo extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/insumos');

  Future<List<Insumo>> buscarTodos() async {
    try {
      final response = await http.get(url, headers: defaultHeaders);

      if (response.statusCode == 200) {
        return _lerCatalogo(response.bodyBytes);
      } else if (response.statusCode == 404) {
        return const [];
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar os insumos cadastrados.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao buscar os insumos. Tente novamente mais tarde.',
      );
    }
  }

  List<Insumo> _lerCatalogo(List<int> bodyBytes) {
    final dados = extrairDadosResposta(bodyBytes);

    final lista = dados is Map<String, dynamic>
        ? (dados['insumos'] ?? dados['itens'])
        : dados;

    if (lista is! List) return const [];

    return lista
        .whereType<Map<String, dynamic>>()
        .map((json) => Insumo.fromJson(json))
        .toList();
  }

  Future<Insumo?> cadastrar(Insumo insumo, int idProprietario) async {
    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(insumo.toJson(idProprietario)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _lerInsumoCriado(response.bodyBytes);
      } else if (response.statusCode == 409) {
        throw ApiException('Já existe um insumo com essa descrição.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar insumo.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao cadastrar insumo. Tente novamente mais tarde.',
      );
    }
  }

  Insumo? _lerInsumoCriado(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) return null;

    final dados = extrairDadosResposta(bodyBytes);

    if (dados is Map<String, dynamic> && dados['id'] != null) {
      return Insumo.fromJson(dados);
    }

    return null;
  }
}
