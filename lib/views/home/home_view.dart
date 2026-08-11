// lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/propriedade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/sessao_em_breve_widget.dart';
import 'package:provider/provider.dart';

// TODO: Certifique-se de realizar os imports corretos dos componentes de safra abaixo:

import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_summary.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_relatorio.dart';
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
@override
  Widget build(BuildContext context) {
    super.build(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();
    
    // 1. Adicione a leitura do SafraViewModel aqui
    final safraVM = context.read<SafraViewModel>(); 

    if (propriedadesVM.idPropriedadeSelecionada != null) {
      final idPropriedade = propriedadesVM.idPropriedadeSelecionada!;

      // Gatilho original dos Talhões
      if (idPropriedade != talhoesVM.idPropriedadeAtual) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          talhoesVM.carregarTalhoes(idPropriedade);
        });
      }

      // 2. NOVO GATILHO: Carrega os dados da Safra quando a propriedade for selecionada ou mudar
      // Ele verifica se a propriedade mudou ou se os dados ainda não foram carregados
      if (idPropriedade != safraVM.propriedadeIdAtual || !safraVM.dadosCarregados) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          safraVM.carregarDadosDaPropriedade(idPropriedade);
        });
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white, 
                child: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start, 
                  labelColor: Color(0xFF67835C),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF67835C),
                  indicatorWeight: 3.0,
                  dividerColor: Colors.transparent, 
                  tabs: [
                    Tab(text: 'Início'),
                    Tab(text: 'Dashboard'),
                  ],
                ),
              ),
              // Conteúdo das abas
              Expanded(
                child: TabBarView(
                  children: [
                    _buildInicioTab(propriedadesVM, context),
                    // Passamos o context para ter acesso aos Providers no Dashboard
                    _buildDashboardTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInicioTab(PropriedadesUsuarioViewModel propriedadesVM, BuildContext context) {
    if (propriedadesVM.isLoading && propriedadesVM.propriedades.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF67835C)));
    }

    if (propriedadesVM.idPropriedadeSelecionada == null || propriedadesVM.propriedades.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma propriedade cadastrada ou selecionada.\nUse o menu superior para adicionar uma.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final propriedadeSelecionada = propriedadesVM.propriedades.firstWhere(
      (p) => p.id == propriedadesVM.idPropriedadeSelecionada,
      orElse: () => propriedadesVM.propriedades.first, 
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF67835C),
                ),
              ),
              const SizedBox(height: 16),
              
              CardPropriedadeWidget(
                propriedade: propriedadeSelecionada,
              ),

              const SizedBox(height: 24),

              buildSecaoEmBreve('Atividades :'),
            ],
          ),
        ),

        Expanded(
          child: Consumer<TalhoesViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF67835C)));
              }

              if (vm.talhoes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 64, color: Color(0xFF67835C)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CadastrarTalhaoView(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cadastrar Novo Talhão',
                        style: TextStyle(color: Color(0xFF67835C), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final safraVM = context.watch<SafraViewModel>();

    // Mostra um indicador de carregamento caso esteja buscando as safras pela primeira vez
    if (safraVM.isLoading && safraVM.safras.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF67835C)));
    }

    // Caso a requisição retorne erro
    if (safraVM.mensagemErro != null && safraVM.safras.isEmpty) {
       return Center(
         child: Text(
           safraVM.mensagemErro!, 
           style: const TextStyle(color: Colors.red),
           textAlign: TextAlign.center,
         )
       );
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Selecionador de Safra devidamente conectado
            SafraSelectorWidget(
              safras: safraVM.safras, 
              safraSelecionada: safraVM.safraSelecionada, 
              onSelecionar: (safra) {
                safraVM.selecionarSafra(safra);
              },
              mostrarAcoes: false, 
            ),
            
            const SizedBox(height: 16),

            // 2. Resumo da Safra atual conectado
            if (safraVM.safraSelecionada != null) ...[
              SafraSummaryCard(safra: safraVM.safraSelecionada!),
              const SizedBox(height: 16),
            ],
            
            // 3. Gráficos, Paineis Financeiros e Listagem de Eventos conectados
            SafraRelatorioWidget(
              eventos: safraVM.relatorio, 
              isLoading: safraVM.isLoadingRelatorio, 
              mostrarTitulo: false, 
            ),
          
          ],
        ),
      ),
    );
  }
}