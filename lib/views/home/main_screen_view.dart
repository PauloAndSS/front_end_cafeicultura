import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/armazem_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/atividades_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_app_bar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';
import 'package:provider/provider.dart';

import 'financeiro_view.dart';
import '../talhao/talhao_view.dart';
import 'home_view.dart';
import '../../viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  late PageController _pageController;
  NavegacaoViewModel? _navViewModel;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: context.read<NavegacaoViewModel>().indiceAtual,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropriedadesUsuarioViewModel>().carregarPropriedades();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = context.read<NavegacaoViewModel>();
    if (identical(viewModel, _navViewModel)) {
      return;
    }

    _navViewModel?.removeListener(_sincronizarPageController);
    _navViewModel = viewModel;
    viewModel.addListener(_sincronizarPageController);
  }

  @override
  void dispose() {
    _navViewModel?.removeListener(_sincronizarPageController);
    _pageController.dispose();
    super.dispose();
  }

  void _sincronizarPageController() {
    if (_pageController.hasClients) {
      final paginaAtual = _pageController.page?.round() ?? 0;
      if (paginaAtual != _navViewModel!.indiceAtual) {
        _pageController.animateToPage(
          _navViewModel!.indiceAtual,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (_navViewModel!.indiceAtual != index) {
      _navViewModel!.alterarAba(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      const HomeView(),
      const AtividadesView(),
      const TalhaoView(),
      const FinanceiroView(),
      const ArmazemView(),
    ];

    return Scaffold(
      backgroundColor: AppCores.fundo,
      resizeToAvoidBottomInset: false,

      appBar: const CustomAppBar(),

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: telas,
      ),

      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
