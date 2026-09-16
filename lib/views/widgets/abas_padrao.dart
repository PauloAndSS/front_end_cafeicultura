import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

const double _alturaDoDegrade = 6.0;

const double alturaDaFaixaDeAbas = kTextTabBarHeight + _alturaDoDegrade;

TabBar abasPadrao({
  required List<Tab> abas,
  TabController? controller,
  bool rolavel = false,
}) {
  return TabBar(
    controller: controller,
    isScrollable: rolavel,
    tabAlignment: rolavel ? TabAlignment.start : null,
    padding: rolavel ? const EdgeInsets.symmetric(horizontal: 12) : null,
    tabs: abas,
  );
}

class FaixaDeAbas extends StatelessWidget {
  final TabBar abas;
  final Color corDeFundo;

  const FaixaDeAbas({
    super.key,
    required this.abas,
    this.corDeFundo = AppCores.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kTextTabBarHeight,
          child: ColoredBox(color: corDeFundo, child: abas),
        ),
        SizedBox(
          height: _alturaDoDegrade,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppCores.sombraChrome,
                  AppCores.sombraChrome.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BarraDeAbas extends StatelessWidget implements PreferredSizeWidget {
  final List<Tab> abas;
  final TabController? controller;
  final bool rolavel;
  final Color corDeFundo;

  const BarraDeAbas({
    super.key,
    required this.abas,
    this.controller,
    this.rolavel = false,
    this.corDeFundo = AppCores.fundo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(alturaDaFaixaDeAbas);

  @override
  Widget build(BuildContext context) {
    return FaixaDeAbas(
      corDeFundo: corDeFundo,
      abas: abasPadrao(abas: abas, controller: controller, rolavel: rolavel),
    );
  }
}
