import 'package:flutter/material.dart';

class NavegacaoViewModel extends ChangeNotifier {
  int _indiceAtual = 0;

  int get indiceAtual => _indiceAtual;

  void alterarAba(int novoIndice) {
    _indiceAtual = novoIndice;
    notifyListeners();
  }
}
