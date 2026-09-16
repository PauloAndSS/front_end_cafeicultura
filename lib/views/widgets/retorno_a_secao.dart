import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute<void>> observadorDeRotas =
    RouteObserver<PageRoute<void>>();

mixin RetornoASecaoMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  bool? _visivel;

  PageRoute<void>? _rotaObservada;

  SecaoPrincipal get secaoDoRetorno;

  void aoRetornarASecao();

  void observarRetornoASecao(BuildContext context) {
    _observarRota(context);

    final visivel =
        context.watch<NavegacaoViewModel>().secaoAtual == secaoDoRetorno;

    final voltouASerVisivel = _visivel == false && visivel;

    _visivel = visivel;

    if (voltouASerVisivel) _agendarRetorno();
  }

  void _observarRota(BuildContext context) {
    final rota = ModalRoute.of(context);

    if (rota is! PageRoute<void> || identical(rota, _rotaObservada)) return;

    if (_rotaObservada != null) observadorDeRotas.unsubscribe(this);

    _rotaObservada = rota;
    observadorDeRotas.subscribe(this, rota);
  }

  void _agendarRetorno() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) aoRetornarASecao();
    });
  }

  @override
  void didPopNext() {
    if (_visivel == true) _agendarRetorno();
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  @override
  void dispose() {
    observadorDeRotas.unsubscribe(this);
    super.dispose();
  }
}
