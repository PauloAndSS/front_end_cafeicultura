import 'package:flutter/foundation.dart';

class AtividadesMudaram extends ChangeNotifier {
  int _geracao = 0;

  int get geracao => _geracao;

  void invalidar() {
    _geracao++;
    notifyListeners();
  }
}
