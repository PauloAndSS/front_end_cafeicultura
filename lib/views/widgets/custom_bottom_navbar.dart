import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

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

class CustomBottomNavBar extends StatelessWidget {
  final bool ocultarSelecao;

  const CustomBottomNavBar({super.key, this.ocultarSelecao = false});

  void _onTabTapped(BuildContext context, int index) {
    final navVM = context.read<NavegacaoViewModel>();

    if (navVM.indiceAtual != index) {
      navVM.alterarAba(index);
    } else {
      navVM.reiniciarSecaoAtual();
    }

    if (ocultarSelecao) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavegacaoViewModel>();
    final int currentIndex = navVM.indiceAtual;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppCores.verdeSecundario,
          indicatorColor: !ocultarSelecao
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (!ocultarSelecao && states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (!ocultarSelecao && states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white, size: 30);
            }
            return const IconThemeData(color: Colors.white70, size: 26);
          }),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: ocultarSelecao ? 0 : currentIndex,
          onDestinationSelected: (index) => _onTabTapped(context, index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: SecaoPrincipal.values.map((secao) {
            return NavigationDestination(
              icon: Icon(secao.icone),
              selectedIcon: Icon(secao.iconeSelecionado),
              label: secao.rotulo,
            );
          }).toList(),
        ),
      ),
    );
  }
}
