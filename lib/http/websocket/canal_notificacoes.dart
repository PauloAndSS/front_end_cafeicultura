import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';
import 'package:web_socket_channel/io.dart';

Uri uriDoSocket(String baseUrl) {
  final base = Uri.parse(baseUrl);

  return Uri(scheme: 'ws', host: base.host, port: base.port, path: '/');
}

Notificacao? interpretarMensagem(dynamic mensagem) {
  if (mensagem is! String) return null;

  try {
    final json = jsonDecode(mensagem);

    if (json is! Map<String, dynamic>) return null;

    return Notificacao.fromJson(json);
  } catch (_) {
    return null;
  }
}

class CanalNotificacoes {
  static const Duration esperaInicial = Duration(seconds: 1);
  static const Duration esperaMaxima = Duration(seconds: 30);
  static const Duration intervaloDePing = Duration(seconds: 30);

  final _entrega = StreamController<Notificacao>.broadcast();

  IOWebSocketChannel? _canal;
  StreamSubscription<dynamic>? _inscricao;
  Timer? _reconexao;
  Duration _espera = esperaInicial;
  bool _querConectado = false;

  Stream<Notificacao> get notificacoes => _entrega.stream;

  bool get conectado => _canal != null;

  void conectar() {
    if (_querConectado) return;

    _querConectado = true;
    _espera = esperaInicial;
    _abrir();
  }

  void reconectarSeCaiu() {
    if (!_querConectado || _canal != null) return;

    _reconexao?.cancel();
    _espera = esperaInicial;
    _abrir();
  }

  void desconectar() {
    _querConectado = false;
    _reconexao?.cancel();
    _reconexao = null;
    _fechar();
  }

  void dispose() {
    desconectar();
    _entrega.close();
  }

  void _abrir() {
    final cookie = BaseService.sessionCookie;

    if (cookie == null) return;

    final endereco = uriDoSocket(
      BaseService.resolveBaseUrl(
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      ),
    );

    final canal = IOWebSocketChannel.connect(
      endereco,
      headers: {'Cookie': cookie},
      pingInterval: intervaloDePing,
    );

    _canal = canal;

    _inscricao = canal.stream.listen(
      _receber,
      onDone: _agendarReconexao,
      onError: (_) => _agendarReconexao(),
      cancelOnError: true,
    );
  }

  void _receber(dynamic mensagem) {
    _espera = esperaInicial;

    final notificacao = interpretarMensagem(mensagem);

    if (notificacao != null) _entrega.add(notificacao);
  }

  void _agendarReconexao() {
    _fechar();

    if (!_querConectado) return;

    _reconexao?.cancel();
    _reconexao = Timer(_espera, _abrir);

    final dobrada = _espera * 2;
    _espera = dobrada > esperaMaxima ? esperaMaxima : dobrada;
  }

  void _fechar() {
    _inscricao?.cancel();
    _inscricao = null;

    _canal?.sink.close();
    _canal = null;
  }
}
