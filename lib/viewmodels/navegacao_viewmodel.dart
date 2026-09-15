import 'package:flutter/material.dart';

enum SecaoPrincipal { home, atividades, talhoes, financeiro, armazem }

class NavegacaoViewModel extends ChangeNotifier {
  int _indiceAtual = 0;
  int _geracaoDeReinicio = 0;
  SecaoPrincipal? _secaoDoReinicio;

  int get indiceAtual => _indiceAtual;

  SecaoPrincipal get secaoAtual => SecaoPrincipal.values[_indiceAtual];

  int get geracaoDeReinicio => _geracaoDeReinicio;

  SecaoPrincipal? get secaoDoReinicio => _secaoDoReinicio;

  void alterarAba(int novoIndice) {
    _indiceAtual = novoIndice;
    notifyListeners();
  }

  void reiniciarSecaoAtual() {
    _secaoDoReinicio = secaoAtual;
    _geracaoDeReinicio++;
    notifyListeners();
  }

  void irParaInicio() {
    _indiceAtual = SecaoPrincipal.home.index;
    _secaoDoReinicio = SecaoPrincipal.home;
    _geracaoDeReinicio++;
    notifyListeners();
  }
}
