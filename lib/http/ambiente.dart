import 'package:flutter/foundation.dart';

abstract final class Ambiente {
  static const bool emProducao = true;

  static const String urlProducao = 'https://api.sysgrano.app/api/v1';
  static const String urlLocalEmulador = 'http://10.0.2.2:3333/api/v1';
  static const String urlLocal = 'http://localhost:3333/api/v1';

  static bool get usaProducao => kReleaseMode || emProducao;
}
