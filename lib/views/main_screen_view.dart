import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_app_bar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';
import 'package:provider/provider.dart';

import 'financeiro_view.dart';
import 'eventos/talhao_view.dart';

import '../viewmodels/navegacao_viewmodel.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    
    // Inicializa o controlador da página com a aba atual salva no ViewModel
    final vm = Provider.of<NavegacaoViewModel>(context, listen: false);
    _pageController = PageController(initialPage: vm.indiceAtual);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropriedadesUsuarioViewModel>(context, listen: false)
          .carregarPropriedades();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Acionado quando o usuário arrasta a tela para o lado
  void _onPageChanged(int index) {
    final vm = Provider.of<NavegacaoViewModel>(context, listen: false);
    if (vm.indiceAtual != index) {
      vm.alterarAba(index); // Atualiza o estado do rodapé sem recriar a página
    }
  }

  // Acionado quando o usuário clica direto em um ícone do rodapé
  void _onBottomNavTapped(int index) {
    final vm = Provider.of<NavegacaoViewModel>(context, listen: false);
    vm.alterarAba(index);
    
    // Faz a animação de transição suave até a página clicada
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavegacaoViewModel>();

    final telas = [
      const SizedBox.shrink(),   // 0: Home 
      const SizedBox.shrink(),  // 1: Atividades (Eventos)
      const TalhaoView(),       // 2: Talhões
      const SizedBox.shrink(),  // 3: Armazém
      const FinanceiroView(),   // 4: Financeiro
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false, 
      
      appBar: const CustomAppBar(),

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: telas,
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: vm.indiceAtual,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}