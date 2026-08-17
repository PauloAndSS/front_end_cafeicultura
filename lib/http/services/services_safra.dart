import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
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

  /// Busca o relatório de eventos agrícolas de uma safra específica.
  ///
  /// Cada item da resposta vem no formato `{ "modulo": "...", "dados": {...} }`.
  /// O `dados` é o que os construtores `fromJson` de `EventoAgricola`
  /// esperam receber; o `modulo` diz qual subclasse concreta instanciar.
  /// Módulos ainda não suportados no app são ignorados silenciosamente
  /// (não derrubam o relatório inteiro).
  Future<List<EventoAgricola>> buscarRelatorio({
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
        return _mapearEventos(dadosEventos);
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

  /// Busca o relatório de eventos de uma safra recortado por um talhão.
  ///
  /// Mesma resposta de [buscarRelatorio] — envelope `{modulo, dados}` — só
  /// que quem filtra pelo talhão é o backend, e não o app depois de baixar
  /// tudo: a safra inteira de uma propriedade grande é muito maior do que a
  /// fatia de um talhão só.
  Future<List<EventoAgricola>> buscarRelatorioDoTalhao({
    required int idPropriedade,
    required int idSafra,
    required int idTalhao,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$url/propriedade/$idPropriedade/safra/$idSafra/talhao/$idTalhao/eventos'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dadosEventos = extrairDadosResposta(response.bodyBytes);
        return _mapearEventos(dadosEventos);
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar relatório do talhão.',
        );
      }
    } on ApiException catch (e) {
      // Talhão sem nenhuma atividade na safra é o caso mais comum de todos,
      // e o backend o comunica como erro. Sem esta conversão a tela mostraria
      // vermelho onde deveria mostrar estado vazio.
      if (_isMensagemSemRegistro(e.mensagem)) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar relatório do talhão. Tente novamente mais tarde.');
    }
  }

  /// Desembrulha cada `{modulo, dados}` no model concreto correspondente.
  ///
  /// Delega ao [EventoFactory], que é o mesmo desembrulho que a listagem de
  /// atividades já usa: um módulo que o app ainda não modela vira
  /// `EventoGenerico` em vez de sumir do relatório — um evento com título
  /// genérico informa mais do que um buraco silencioso na contagem.
  List<EventoAgricola> _mapearEventos(dynamic dadosEventos) {
    if (dadosEventos is! List) {
      return const [];
    }

    return dadosEventos
        .whereType<Map<String, dynamic>>()
        .map(EventoFactory.fromJson)
        .toList();
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