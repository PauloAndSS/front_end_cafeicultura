import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/navegacao_viewmodel.dart';

import 'home_view.dart';
import 'cafe_view.dart';
import 'funcionarios_view.dart';
import 'financeiro_view.dart';
import 'armazem_view.dart';
import 'talhao_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavegacaoViewModel>();

    final telas = [
      const HomeView(),
      const CafeView(),
      const TalhaoView(),
      const ArmazemView(),
      //const FuncionariosView(), tirado
      const FinanceiroView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: IndexedStack(
        index: vm.indiceAtual,
        children: telas,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),

          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: const Color(0xFF8FA67E),

              indicatorColor: Colors.white.withOpacity(0.18),

              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              iconTheme: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: Colors.white,
                      size: 30,
                    );
                  }

                  return const IconThemeData(
                    color: Colors.white70,
                    size: 26,
                  );
                },
              ),
            ),

            child: NavigationBar(
              height: 85,

              elevation: 0,

              selectedIndex: vm.indiceAtual,

              onDestinationSelected: vm.alterarAba,

              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,

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

                /*NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Funcionários',
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}