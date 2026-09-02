import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response respostaJson(
  Object corpo,
  int status, {
  Map<String, String>? headers,
}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(corpo)),
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      ...?headers,
    },
  );
}

http.Response respostaSemCorpo(int status) => http.Response('', status);

Future<T> comRespostaFixa<T>(
  Future<T> Function() acao,
  http.Response resposta, {
  void Function(http.Request requisicao)? capturar,
}) {
  return http.runWithClient(
    acao,
    () => MockClient((requisicao) async {
      capturar?.call(requisicao);
      return resposta;
    }),
  );
}

Future<T> comFalhaDeRede<T>(Future<T> Function() acao) {
  return http.runWithClient(
    acao,
    () => MockClient((_) async => throw const SocketException('sem rota')),
  );
}

Future<ApiException> erroDe(Future<void> Function() acao) async {
  try {
    await acao();
  } on ApiException catch (e) {
    return e;
  }
  fail('Esperava ApiException, mas a chamada concluiu sem erro.');
}
