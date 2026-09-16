import 'package:flutter/foundation.dart';

/// Sinaliza para outras telas que os dados financeiros (despesas) mudaram
/// em algum lugar do app — por exemplo, ao cadastrar ou excluir uma despesa
/// na tela de Financeiro — para que possam invalidar seus próprios caches
/// e recarregar o relatório financeiro.
class FinanceiroMudou extends ChangeNotifier {
  int _geracao = 0;

  int get geracao => _geracao;

  void invalidar() {
    _geracao++;
    notifyListeners();
  }
}
