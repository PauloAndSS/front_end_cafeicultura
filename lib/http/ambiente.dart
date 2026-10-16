import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AlvoDaApi { local, dev, producao }

abstract final class Ambiente {
  static const AlvoDaApi alvo = AlvoDaApi.dev;

  static const String urlProducao = 'https://api.sysgrano.app/api/v1';
  static const String urlDev = 'https://dev.sysgrano.app/api/v1';
  static const String urlLocalEmulador = 'http://10.0.2.2:3333/api/v1';
  static const String urlLocal = 'http://localhost:3333/api/v1';

  static const String _variavelDaChaveDaApi = 'API_KEY';

  static AlvoDaApi get alvoEfetivo =>
      kReleaseMode ? AlvoDaApi.producao : alvo;

  static String urlBase({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    return switch (alvoEfetivo) {
      AlvoDaApi.producao => urlProducao,
      AlvoDaApi.dev => urlDev,
      AlvoDaApi.local => (!isWeb && platform == TargetPlatform.android)
          ? urlLocalEmulador
          : urlLocal,
    };
  }

  static String? get chaveDaApi {
    if (!dotenv.isInitialized) return null;

    final chave = dotenv.maybeGet(_variavelDaChaveDaApi)?.trim();

    return (chave == null || chave.isEmpty) ? null : chave;
  }
}
