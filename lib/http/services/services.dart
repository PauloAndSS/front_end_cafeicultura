import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:http/http.dart' as http;

abstract class BaseService {
  final String baseUrl = 'http://10.0.2.2:3333/api/v1';
  static String? sessionCookie;

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
    String? rawCookie = response.headers['set-cookie'];
    
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      print('✅ COOKIE SALVO COM SUCESSO: $sessionCookie');
    } else {
      print('❌ O BACK-END NÃO ENVIOU COOKIE NO CADASTRO');
    }
  }

  Never tratarErroRequisicao(List<int> bodyBytes, {String fallbackMsg = 'Erro na requisição.'}) {
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
      throw ApiException(fallbackMsg);
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(fallbackMsg);
    }
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
} 