import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class BaseService {
  static String resolveBaseUrl({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb) {
      return 'http://localhost:3333/api/v1';
    }

    if (platform == TargetPlatform.android) {
      return 'http://10.0.2.2:3333/api/v1';
    }

    return 'http://localhost:3333/api/v1';
  }

  String get baseUrl => resolveBaseUrl(
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      );

  String get recurso;

  Uri get url => rota();

  Uri rota([String caminho = '', Map<String, String>? query]) {
    final sufixo = caminho.isEmpty ? '' : '/$caminho';
    final uri = Uri.parse('$baseUrl/$recurso$sufixo');

    return query == null ? uri : uri.replace(queryParameters: query);
  }

  static String? sessionCookie;

  static bool logarCorpoDeSucesso = false;

  @protected
  bool get corpoSensivel => false;

  Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (sessionCookie != null) {
      headers['Cookie'] = sessionCookie!;
    }

    return headers;
  }

  static void atualizarCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];

    if (rawCookie == null) {
      debugPrint('O back-end não enviou cookie de sessão nesta resposta.');
      return;
    }

    final fimDoValor = rawCookie.indexOf(';');
    sessionCookie =
        fimDoValor == -1 ? rawCookie : rawCookie.substring(0, fimDoValor);
  }

  bool sucesso(http.Response response) => response.statusCode >= 200 && response.statusCode < 300;

  bool isEmptyList(http.Response response) {
    if (response.statusCode != 404) return false;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes)) is Map<String, dynamic>;
    } catch (_) {
      return false;
    }
  }

  @protected
  Future<R> executarRequisicao<R>({
    required Future<http.Response> Function() enviar,
    required R Function(http.Response resposta) aoSucesso,
    R Function()? aoListaVazia,
    Map<int, String>? errosPorStatus,
    required String erroMsg,
    required String acao,
  }) async {
    try {
      final response = await enviar();

      if (sucesso(response)) {
        _logarSucesso(response, acao);
        return aoSucesso(response);
      }

      _logarResposta(response, acao);

      final erroDeStatus = errosPorStatus?[response.statusCode];
      if (erroDeStatus != null) throw ApiException(erroDeStatus);

      if (aoListaVazia != null && isEmptyList(response)) return aoListaVazia();

      tratarErroRequisicao(
        response.bodyBytes,
        fallbackMsg: erroMsg,
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      if (aoListaVazia != null && e.indicaAusenciaDeRegistros) {
        return aoListaVazia();
      }
      rethrow;
    } catch (e, rastro) {
      _logarExcecao(acao, e, rastro);
      throw ApiException(
        'Falha na comunicação ao $acao. Tente novamente mais tarde.',
      );
    }
  }

  void _logarResposta(http.Response response, String acao) {
    if (!kDebugMode) return;

    final requisicao = response.request;
    final enviado = _corpoEnviado(requisicao);
    final corpo = utf8.decode(response.bodyBytes, allowMalformed: true);

    debugPrint('[API] ${requisicao?.method} ${requisicao?.url}');
    if (enviado != null) debugPrint('[API] enviado: $enviado');
    debugPrint('[API] falha ao $acao | status: ${response.statusCode}');
    debugPrint('[API] corpo: ${corpo.isEmpty ? '<vazio>' : corpo}');
  }

  void _logarSucesso(http.Response response, String acao) {
    if (!kDebugMode || !logarCorpoDeSucesso) return;

    final requisicao = response.request;
    final enviado = _corpoEnviado(requisicao);

    debugPrint('[API] ${requisicao?.method} ${requisicao?.url} '
        '| $acao | status: ${response.statusCode}');
    if (enviado != null) debugPrint('[API] enviado: $enviado');
  }

  String? _corpoEnviado(http.BaseRequest? requisicao) {
    if (requisicao is! http.Request) return null;
    if (corpoSensivel) return '<omitido>';

    final corpo = requisicao.body;

    return corpo.isEmpty ? null : corpo;
  }

  void _logarExcecao(String acao, Object erro, StackTrace rastro) {
    if (!kDebugMode) return;

    debugPrint('[API] exceção ao $acao | ${erro.runtimeType}: $erro');
    debugPrint('$rastro');
  }

  Never tratarErroRequisicao(
    List<int> bodyBytes, {
    String fallbackMsg = 'Erro na requisição.',
    int? statusCode,
  }) {
    try {
      final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('erros') && jsonResponse['erros'] is List) {
          final List<dynamic> erros = jsonResponse['erros'];
          final listaMensagens = erros.map((e) => '• ${e['msg']}').toList();

          throw ApiValidationException([fallbackMsg, ...listaMensagens.cast<String>()]);
        }

        if (jsonResponse.containsKey('error') || jsonResponse.containsKey('mensagem')) {
          final backendMsg = jsonResponse['error'] ?? jsonResponse['mensagem'];
          throw ApiException('$fallbackMsg\n$backendMsg');
        }
      }
      _logarFalha(fallbackMsg, statusCode);
      throw ApiException(fallbackMsg);
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      _logarFalha(fallbackMsg, statusCode, e);
      throw ApiException(fallbackMsg);
    }
  }

  void _logarFalha(String fallbackMsg, int? statusCode, [Object? erro]) {
    debugPrint('[API] $fallbackMsg | status: ${statusCode ?? '-'}'
        '${erro == null ? '' : ' | $erro'}');
  }

  dynamic extrairDadosResposta(List<int> bodyBytes) {
    final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

    if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
      return jsonResponse['data'];
    }

    return jsonResponse;
  }

  Map<String, dynamic> extrairDadosPaginados(List<int> bodyBytes) {
    final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

    if (jsonResponse is Map<String, dynamic>) {
      return jsonResponse;
    }

    throw ApiException('Formato de resposta inválido para paginação.');
  }

  /// Um único model a partir do envelope `{ data: {...} }` ou do objeto cru.
  T extrairObjeto<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! Map<String, dynamic>) {
      throw ApiException('Formato de resposta inválido.');
    }

    return fromJson(dados);
  }

  T? extrairObjetoOuNulo<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (bodyBytes.isEmpty) return null;

    final dados = extrairDadosResposta(bodyBytes);

    if (dados is Map<String, dynamic> && dados['id'] != null) {
      return fromJson(dados);
    }

    return null;
  }

  /// Lista sob o envelope `{ data: [...] }` ou array cru.
  List<T> extrairLista<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! List) return const [];

    return dados.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  /// Lista sob uma chave nomeada pelo recurso, ou array cru.
  List<T> extrairListaNomeada<T>(
    List<int> bodyBytes,
    String chave,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

    if (jsonResponse is List) {
      return jsonResponse.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }

    if (jsonResponse is! Map<String, dynamic>) return const [];

    for (final candidata in [chave, 'data']) {
      final lista = jsonResponse[candidata];

      if (lista is List) {
        return lista.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
    }


    _logarFalha(
      'Nenhuma lista encontrada sob "$chave" nem "data" no corpo da resposta',
      null,
    );

    return const [];
  }
}
