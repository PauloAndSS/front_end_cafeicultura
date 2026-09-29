import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

extension _AparenciaDaSecao on SecaoPrincipal {
  String get rotulo {
    switch (this) {
      case SecaoPrincipal.home:
        return 'Home';
      case SecaoPrincipal.atividades:
        return 'Atividades';
      case SecaoPrincipal.talhoes:
        return 'Talhões';
      case SecaoPrincipal.financeiro:
        return 'Financeiro';
      case SecaoPrincipal.armazem:
        return 'Armazém';
    }
  }

  IconData get icone {
    switch (this) {
      case SecaoPrincipal.home:
        return Icons.home_outlined;
      case SecaoPrincipal.atividades:
        return Icons.coffee_outlined;
      case SecaoPrincipal.talhoes:
        return Icons.agriculture_outlined;
      case SecaoPrincipal.financeiro:
        return Icons.attach_money_outlined;
      case SecaoPrincipal.armazem:
        return Icons.warehouse_outlined;
    }
  }

  IconData get iconeSelecionado {
    switch (this) {
      case SecaoPrincipal.home:
        return Icons.home;
      case SecaoPrincipal.atividades:
        return Icons.coffee;
      case SecaoPrincipal.talhoes:
        return Icons.agriculture;
      case SecaoPrincipal.financeiro:
        return Icons.attach_money;
      case SecaoPrincipal.armazem:
        return Icons.warehouse;
    }
  }
}

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  static const _respiroDoRotulo = 4.0;
  static const _folgaDoDestinoRolavel = 24.0;
  static const _escalaMaximaDoRotulo = 1.3;
  static const _duracaoDaRevelacao = Duration(milliseconds: 300);

  final _chavesDosDestinos = {
    for (final secao in SecaoPrincipal.values) secao: GlobalKey(),
  };
  double _larguraDoRotuloMaisLargo = 0;
  (double, double)? _medidasDaBarra;
  int? _ultimoIndiceRevelado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _larguraDoRotuloMaisLargo = _medirRotuloMaisLargo();
  }

  double _medirRotuloMaisLargo() {
    final estilo = _estiloDoRotuloSelecionado();
    final escala = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _escalaMaximaDoRotulo);
    final direcao = Directionality.of(context);

    return SecaoPrincipal.values
        .map((secao) => _larguraDoTexto(secao.rotulo, estilo, escala, direcao))
        .reduce(max);
  }

  TextStyle? _estiloDoRotuloSelecionado() {
    final estiloDaBarra = NavigationBarTheme.of(
      context,
    ).labelTextStyle?.resolve({WidgetState.selected});

    return Theme.of(context).textTheme.bodyMedium?.merge(estiloDaBarra);
  }

  double _larguraDoTexto(
    String texto,
    TextStyle? estilo,
    TextScaler escala,
    TextDirection direcao,
  ) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: direcao,
      textScaler: escala,
      maxLines: 1,
    )..layout();
    final largura = pintor.width;
    pintor.dispose();

    return largura;
  }

  void _onTabTapped(BuildContext context, int index) {
    final navVM = context.read<NavegacaoViewModel>();

    if (navVM.indiceAtual != index) {
      navVM.alterarAba(index);
    } else {
      navVM.reiniciarSecaoAtual();
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _revelarSeMudou(int indice) {
    if (indice == _ultimoIndiceRevelado) return;

    final primeiraRevelacao = _ultimoIndiceRevelado == null;
    _ultimoIndiceRevelado = indice;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revelar(indice, animado: !primeiraRevelacao),
    );
  }

  void _reposicionarSeMedidasMudaram((double, double) medidas, int indice) {
    final medidasAnteriores = _medidasDaBarra;
    _medidasDaBarra = medidas;
    if (medidasAnteriores == null || medidasAnteriores == medidas) return;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revelar(indice, animado: false),
    );
  }

  void _revelar(int indice, {required bool animado}) {
    final secao = SecaoPrincipal.values[indice];
    final contexto = _chavesDosDestinos[secao]?.currentContext;
    if (!mounted || contexto == null || _semViewport(contexto)) return;

    Scrollable.ensureVisible(
      contexto,
      alignment: 0.5,
      duration: animado ? _duracaoDaRevelacao : Duration.zero,
      curve: Curves.easeInOut,
    );
  }

  bool _semViewport(BuildContext contexto) {
    final posicao = Scrollable.of(contexto).position;
    return !posicao.hasViewportDimension || posicao.viewportDimension == 0;
  }

  @override
  Widget build(BuildContext context) {
    final indiceAtual = context.watch<NavegacaoViewModel>().indiceAtual;
    _revelarSeMudou(indiceAtual);

    const raio = BorderRadius.vertical(
      top: Radius.circular(AppEstilos.raioChrome),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppCores.casca,
        borderRadius: raio,
        boxShadow: AppEstilos.sombraChromeInferior,
      ),
      child: ClipRRect(
        borderRadius: raio,
        child: LayoutBuilder(
          builder: (context, constraints) =>
              _construirBarra(context, constraints, indiceAtual),
        ),
      ),
    );
  }

  Widget _construirBarra(
    BuildContext context,
    BoxConstraints constraints,
    int indiceAtual,
  ) {
    final quantidade = SecaoPrincipal.values.length;
    final larguraNecessaria = _larguraDoRotuloMaisLargo + _respiroDoRotulo;
    final cabe = constraints.maxWidth >= quantidade * larguraNecessaria;
    final largura = cabe
        ? constraints.maxWidth
        : quantidade * (larguraNecessaria + _folgaDoDestinoRolavel);
    _reposicionarSeMedidasMudaram((constraints.maxWidth, largura), indiceAtual);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: cabe ? const NeverScrollableScrollPhysics() : null,
        child: SizedBox(
          width: largura,
          child: _construirDestinos(context, indiceAtual),
        ),
      ),
    );
  }

  NavigationBar _construirDestinos(BuildContext context, int indiceAtual) {
    return NavigationBar(
      selectedIndex: indiceAtual,
      onDestinationSelected: (index) => _onTabTapped(context, index),
      destinations: [
        for (final secao in SecaoPrincipal.values)
          NavigationDestination(
            key: _chavesDosDestinos[secao],
            icon: Icon(secao.icone),
            selectedIcon: Icon(secao.iconeSelecionado),
            label: secao.rotulo,
          ),
      ],
    );
  }
}
