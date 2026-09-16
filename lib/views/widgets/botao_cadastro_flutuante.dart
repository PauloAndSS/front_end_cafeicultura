import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BotaoCadastroFlutuante extends StatelessWidget {
  const BotaoCadastroFlutuante({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    required this.estendido,
  });

  final String rotulo;
  final VoidCallback aoTocar;
  final bool estendido;

  static const _duracao = Duration(milliseconds: 220);
  static const _espacoIconeRotulo = 8.0;
  static const _recuoInicial = 16.0;
  static const _recuoFinalColapsado = 16.0;
  static const _folgaDoRotulo = 4.0;
  static const _aberturaMinimaDoTexto = 0.35;

  double _opacidadeDoRotulo(double abertura) =>
      ((abertura - _aberturaMinimaDoTexto) / (1 - _aberturaMinimaDoTexto))
          .clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: estendido ? 1.0 : 0.0),
      duration: _duracao,
      curve: Curves.easeOutCubic,
      builder: (context, abertura, _) {
        return FloatingActionButton.extended(
          onPressed: aoTocar,
          heroTag: null,
          extendedIconLabelSpacing: _espacoIconeRotulo * abertura,
          extendedPadding: EdgeInsetsDirectional.only(
            start: _recuoInicial,
            end: _recuoFinalColapsado + _folgaDoRotulo * abertura,
          ),
          icon: const Icon(Icons.add),
          label: ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: abertura,
              child: Opacity(
                opacity: _opacidadeDoRotulo(abertura),
                child: Text(rotulo, maxLines: 1, softWrap: false),
              ),
            ),
          ),
        );
      },
    );
  }
}

mixin RolagemEstendeCadastroMixin<T extends StatefulWidget> on State<T> {
  bool _cadastroEstendido = true;

  bool get cadastroEstendido => _cadastroEstendido;

  Widget observarRolagemDoCadastro(Widget filho) {
    return NotificationListener<ScrollNotification>(
      onNotification: _aoRolar,
      child: filho,
    );
  }

  bool _aoRolar(ScrollNotification notificacao) {
    if (notificacao.metrics.axis != Axis.vertical) return false;

    if (notificacao is UserScrollNotification) {
      switch (notificacao.direction) {
        case ScrollDirection.reverse:
          _definirEstendido(false);
        case ScrollDirection.forward:
          _definirEstendido(true);
        case ScrollDirection.idle:
          break;
      }
    } else if (notificacao is ScrollUpdateNotification &&
        notificacao.metrics.pixels <= notificacao.metrics.minScrollExtent) {
      _definirEstendido(true);
    }

    return false;
  }

  void _definirEstendido(bool valor) {
    if (_cadastroEstendido == valor || !mounted) return;

    setState(() => _cadastroEstendido = valor);
  }
}
