import 'package:flutter/foundation.dart';

/// Impede `notifyListeners()` depois do `dispose()`.
///
/// Vive num mixin próprio porque um ViewModel de atividade agrícola combina
/// vários carregadores ([CarregarResponsaveisMixin], [CarregarInsumosMixin]).
/// Se cada um trouxesse sua própria flag e seu próprio `dispose`, o Dart
/// resolveria `notificarComSeguranca` pela linearização — o último mixin da
/// cláusula `with` venceria e checaria só a flag dele. Funcionaria por
/// coincidência e quebraria no dia em que alguém trocasse a ordem.
///
/// Os membros são públicos de propósito: membro privado só é visível dentro da
/// biblioteca que o declara, então um `_safeNotify` aqui não seria chamável por
/// quem usa o mixin.
mixin DescarteSeguroMixin on ChangeNotifier {
  bool _estaDescartado = false;
  bool get estaDescartado => _estaDescartado;

  @override
  void dispose() {
    _estaDescartado = true;
    super.dispose();
  }

  void notificarComSeguranca() {
    if (!_estaDescartado) {
      notifyListeners();
    }
  }
}
