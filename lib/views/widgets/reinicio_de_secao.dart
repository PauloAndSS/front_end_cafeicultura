import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:provider/provider.dart';

const Duration _duracaoDaVoltaAoTopo = Duration(milliseconds: 300);

mixin ReinicioDeSecaoMixin<T extends StatefulWidget> on State<T> {
  int? _geracaoTratada;

  SecaoPrincipal get secaoDoReinicio;

  void aoReiniciarSecao();

  void observarReinicioDeSecao(BuildContext context) {
    final navegacao = context.watch<NavegacaoViewModel>();
    final geracao = navegacao.geracaoDeReinicio;

    if (_geracaoTratada == null) {
      _geracaoTratada = geracao;
      return;
    }

    if (geracao == _geracaoTratada) return;

    _geracaoTratada = geracao;

    if (navegacao.secaoDoReinicio != secaoDoReinicio) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) aoReiniciarSecao();
    });
  }
}

void voltarAoTopo(ScrollController controlador) {
  if (!controlador.hasClients) return;

  controlador.animateTo(
    0,
    duration: _duracaoDaVoltaAoTopo,
    curve: Curves.easeOut,
  );
}
