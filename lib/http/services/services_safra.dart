import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:http/http.dart' as http;

class ServicesSafra extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/safras');

  // getters
  Future<List<Safra>> buscarPorPropriedade(int idPropriedade) async {
    try {
      final response = await http.get(
        Uri.parse('$url/propriedade/$idPropriedade/safras/todas'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dadosSafras = extrairDadosResposta(response.bodyBytes);
        return dadosSafras.map<Safra>((safra) => Safra.fromJson(safra)).toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar safras da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar safras da propriedade. Tente novamente mais tarde.');
    }
  }

  Future<List<SafraEvento>> buscarRelatorio({
    required int idPropriedade,
    required int idSafra,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$url/propriedade/$idPropriedade/safra/$idSafra/eventos'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dadosEventos = extrairDadosResposta(response.bodyBytes);
        return dadosEventos.map<SafraEvento>((evento) => SafraEvento.fromJson(evento)).toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar relatório da safra.',
        );
      }
    } on ApiException catch (e) {
      if (_isMensagemSemRegistro(e.mensagem)) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar relatório da safra. Tente novamente mais tarde.');
    }
  }

  // cadastro
  Future<bool> cadastrar({
    required int idPropriedade,
    DateTime? dataInicio,
  }) async {
    try {
      final payload = {
        'idPropriedade': idPropriedade,
        'dataInicio': (dataInicio ?? DateTime.now()).toUtc().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$url/'),
        headers: defaultHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar safra.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao cadastrar safra. Tente novamente mais tarde.');
    }
  }

  // updates
  Future<bool> encerrar(int idSafra, {DateTime? dataFim}) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$idSafra/finalizar'),
        headers: defaultHeaders,
        body: jsonEncode({
          'dataFim': (dataFim ?? DateTime.now()).toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao encerrar safra.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao encerrar safra. Tente novamente mais tarde.');
    }
  }

  Future<bool> reativar(int idSafra) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$idSafra/reativar'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao reativar safra.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao reativar safra. Tente novamente mais tarde.');
    }
  }

  /// Detecta se uma mensagem de erro da API está, na verdade, só
  /// informando que não há eventos cadastrados ainda para a safra (não é
  /// um erro de fato).
  bool _isMensagemSemRegistro(String mensagem) {
    final normalizada = _removerAcentos(mensagem.toLowerCase());

    final indicaAusencia = normalizada.contains('nao possui') ||
        normalizada.contains('nenhum') ||
        normalizada.contains('sem eventos') ||
        normalizada.contains('sem registro');

    final indicaEventos = normalizada.contains('evento') ||
        normalizada.contains('registrad') ||
        normalizada.contains('exemplo') ||
        normalizada.contains('relatorio');

    return indicaAusencia && indicaEventos;
  }

  String _removerAcentos(String texto) {
    const comAcento = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    var resultado = texto;
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }
}
