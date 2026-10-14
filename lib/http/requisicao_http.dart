import 'dart:convert';

import 'package:http/http.dart' as http;

enum VerboHttp {
  get,
  post,
  put,
  patch,
  delete;

  bool get alteraDados => this != VerboHttp.get;
}

class RequisicaoHttp {
  static const limiteDeLeitura = Duration(seconds: 20);
  static const limiteDeEscrita = Duration(seconds: 30);

  final VerboHttp verbo;
  final Uri rota;
  final Object? corpo;
  final Duration? _limiteEspecifico;

  const RequisicaoHttp._(this.verbo, this.rota, {this.corpo, Duration? limite})
      : _limiteEspecifico = limite;

  const RequisicaoHttp.get(Uri rota, {Duration? limite})
      : this._(VerboHttp.get, rota, limite: limite);

  const RequisicaoHttp.post(Uri rota, {Object? corpo, Duration? limite})
      : this._(VerboHttp.post, rota, corpo: corpo, limite: limite);

  const RequisicaoHttp.put(Uri rota, {Object? corpo, Duration? limite})
      : this._(VerboHttp.put, rota, corpo: corpo, limite: limite);

  const RequisicaoHttp.patch(Uri rota, {Object? corpo, Duration? limite})
      : this._(VerboHttp.patch, rota, corpo: corpo, limite: limite);

  const RequisicaoHttp.delete(Uri rota, {Object? corpo, Duration? limite})
      : this._(VerboHttp.delete, rota, corpo: corpo, limite: limite);

  bool get alteraDados => verbo.alteraDados;

  Duration get limite =>
      _limiteEspecifico ?? (alteraDados ? limiteDeEscrita : limiteDeLeitura);

  Future<http.Response> enviar(Map<String, String> headers) {
    final corpoJson = corpo == null ? null : jsonEncode(corpo);

    final resposta = switch (verbo) {
      VerboHttp.get => http.get(rota, headers: headers),
      VerboHttp.post => http.post(rota, headers: headers, body: corpoJson),
      VerboHttp.put => http.put(rota, headers: headers, body: corpoJson),
      VerboHttp.patch => http.patch(rota, headers: headers, body: corpoJson),
      VerboHttp.delete => http.delete(rota, headers: headers, body: corpoJson),
    };

    return resposta.timeout(limite);
  }
}
