import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/main_screen_view.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool ocultarSelecao;

  const CustomBottomNavBar({
    super.key,
    this.ocultarSelecao = false,
  });

  void _onTabTapped(BuildContext context, int index) {
    final navVM = context.read<NavegacaoViewModel>();

    if (navVM.indiceAtual != index) {
      navVM.alterarAba(index);
    }

    if (ocultarSelecao) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreenView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // O footer observa o estado global sozinho
    final navVM = context.watch<NavegacaoViewModel>();
    final int currentIndex = navVM.indiceAtual;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF8FA67E),
          indicatorColor: !ocultarSelecao
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) {
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
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) {
              if (!ocultarSelecao && states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 30);
              }
              return const IconThemeData(color: Colors.white70, size: 26);
            },
          ),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: ocultarSelecao ? 0 : currentIndex,
          onDestinationSelected: (index) => _onTabTapped(context, index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.coffee_outlined),
              selectedIcon: Icon(Icons.coffee),
              label: 'Atividades',
            ),
            NavigationDestination(
              icon: Icon(Icons.agriculture_outlined),
              selectedIcon: Icon(Icons.agriculture),
              label: 'Talhões',
            ),
            NavigationDestination(
              icon: Icon(Icons.warehouse_outlined),
              selectedIcon: Icon(Icons.warehouse),
              label: 'Armazém',
            ),
            NavigationDestination(
              icon: Icon(Icons.attach_money_outlined),
              selectedIcon: Icon(Icons.attach_money),
              label: 'Financeiro',
            ),
          ],
        ),
      ),
    );
  }
}