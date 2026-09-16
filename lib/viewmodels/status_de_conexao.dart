import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';

class StatusDeConexao extends ChangeNotifier {
  bool _semConexao = false;
  bool _verificando = false;

  bool get semConexao => _semConexao;

  bool get verificando => _verificando;

  void registrarFalha() {
    if (_semConexao || _verificando) return;

    _verificar();
  }

  Future<void> tentarNovamente() => _verificar();

  Future<void> _verificar() async {
    if (_verificando) return;

    _verificando = true;
    notifyListeners();

    final respondeu = await BaseService.servidorRespondeu();

    _verificando = false;
    _semConexao = !respondeu;
    notifyListeners();
  }
}
