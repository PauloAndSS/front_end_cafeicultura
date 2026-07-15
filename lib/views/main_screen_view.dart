import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

import 'financeiro_view.dart';
import 'eventos/talhao_view.dart';

import '../viewmodels/navegacao_viewmodel.dart';

class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavegacaoViewModel>();

    final telas = [
      const SizedBox.shrink(),   // 0: Home (Ajustar depois para a view real da Home)
      const SizedBox.shrink(),  // Atividades (Eventos) (Placeholder - Substitua pela View correta)
      const TalhaoView(),  
      const SizedBox.shrink(), // Armazém (Placeholder - Substitua pela View correta)
      const FinanceiroView(), //Financeiro (Placeholder - Substitua pela View correta)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 👉 O Cabeçalho Fixo inserido aqui!
      appBar: CustomAppBar(),

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
              indicatorColor: Colors.white.withValues(alpha: 0.18),
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
        ),
      ),
    );
  }
}