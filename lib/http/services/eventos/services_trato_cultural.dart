import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/tipo_trato.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo_utilizado.dart';
import 'package:http/http.dart' as http;

class ServicesTratoCultural extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/tratosculturais');

  Future<List<TratoCultural>> buscarPorPropriedade(
    int idPropriedade,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$url/propriedade/$idPropriedade'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dados = extrairDadosResposta(response.bodyBytes);

        return (dados as List)
            .map((json) => TratoCultural.fromJson(json))
            .toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar tratos culturais da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao buscar tratos culturais. Tente novamente mais tarde.',
      );
    }
  }

  Future<List<TratoCultural>> buscarPorTalhao(
    int idPropriedade,
    int idTalhao,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$url/propriedade/$idPropriedade/talhao/$idTalhao'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dados = extrairDadosResposta(response.bodyBytes);

        return (dados as List)
            .map((json) => TratoCultural.fromJson(json))
            .toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar tratos culturais do talhão.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao buscar tratos culturais do talhão. Tente novamente mais tarde.',
      );
    }
  }

  Future<bool> finalizar(int idTrato, DateTime dataFim) async {
    final dataUtc = DateTime.utc(dataFim.year, dataFim.month, dataFim.day);

    return _alterar(
      idTrato: idTrato,
      recurso: 'finalizar',
      corpo: {'dataFim': dataUtc.toIso8601String()},
      fallbackMsg: 'Erro ao finalizar trato cultural.',
      acao: 'finalizar trato cultural',
    );
  }

  Future<bool> alterarDescricao(int idTrato, String descricao) async {
    return _alterar(
      idTrato: idTrato,
      recurso: 'descricao',
      corpo: {'descricao': descricao.trim()},
      fallbackMsg: 'Erro ao alterar a descrição do trato cultural.',
      acao: 'alterar a descrição',
    );
  }

  Future<bool> alterarResponsaveis(
    int idTrato,
    List<int> responsaveisIds,
  ) async {
    return _alterar(
      idTrato: idTrato,
      recurso: 'responsaveis',
      corpo: {'responsaveisIds': responsaveisIds},
      fallbackMsg: 'Erro ao alterar os responsáveis do trato cultural.',
      acao: 'alterar os responsáveis',
    );
  }

  Future<bool> alterarInsumos(
    int idTrato,
    List<InsumoUtilizado> insumos,
  ) async {
    return _alterar(
      idTrato: idTrato,
      recurso: 'insumos',
      corpo: {'insumos': insumos.map((insumo) => insumo.toJson()).toList()},
      fallbackMsg: 'Erro ao alterar os insumos do trato cultural.',
      acao: 'alterar os insumos',
    );
  }

  Future<bool> _alterar({
    required int idTrato,
    required String recurso,
    required Map<String, dynamic> corpo,
    required String fallbackMsg,
    required String acao,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$idTrato/$recurso'),
        headers: defaultHeaders,
        body: jsonEncode(corpo),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(response.bodyBytes, fallbackMsg: fallbackMsg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao $acao. Tente novamente mais tarde.',
      );
    }
  }

  Future<List<TipoTrato>> buscarTiposTrato() async {
    try {
      final response = await http.get(
        Uri.parse('$url/tipos'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dados = extrairDadosResposta(response.bodyBytes);

        return (dados as List)
            .map((json) => TipoTrato.fromJson(json))
            .toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar tipos de trato cultural.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao buscar tipos de trato cultural. Tente novamente mais tarde.',
      );
    }
  }

  Future<bool> cadastrar(TratoCultural trato) async {
    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(trato.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar trato cultural.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao cadastrar trato cultural. Tente novamente mais tarde.',
      );
    }
  }
}
