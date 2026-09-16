import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SentinelaDeLeitura extends StatefulWidget {
  static const Duration permanencia = Duration(seconds: 1);
  static const double fracaoMinima = 0.9;

  final String chave;
  final VoidCallback aoLer;
  final Widget child;

  const SentinelaDeLeitura({
    super.key,
    required this.chave,
    required this.aoLer,
    required this.child,
  });

  @override
  State<SentinelaDeLeitura> createState() => _SentinelaDeLeituraState();
}

class _SentinelaDeLeituraState extends State<SentinelaDeLeitura>
    with WidgetsBindingObserver {
  Timer? _contagem;
  bool _leu = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _cancelar();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado != AppLifecycleState.resumed) _cancelar();
  }

  bool get _emPrimeiroPlano =>
      (WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed) ==
      AppLifecycleState.resumed;

  bool get _rotaAtiva => ModalRoute.of(context)?.isCurrent ?? true;

  void _aoMudarVisibilidade(VisibilityInfo info) {
    if (_leu) return;

    if (info.visibleFraction < SentinelaDeLeitura.fracaoMinima) {
      _cancelar();
      return;
    }

    _contagem ??= Timer(SentinelaDeLeitura.permanencia, _concluir);
  }

  void _concluir() {
    _contagem = null;

    if (!mounted || !_emPrimeiroPlano || !_rotaAtiva) return;

    _leu = true;
    widget.aoLer();
  }

  void _cancelar() {
    _contagem?.cancel();
    _contagem = null;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('leitura-${widget.chave}'),
      onVisibilityChanged: _aoMudarVisibilidade,
      child: widget.child,
    );
  }
}
