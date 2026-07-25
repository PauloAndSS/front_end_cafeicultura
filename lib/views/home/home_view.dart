import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/propriedade_card.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? _ultimaPropriedadeCarregada;

  @override
  Widget build(BuildContext context) {
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada != null && 
        propriedadesVM.idPropriedadeSelecionada != _ultimaPropriedadeCarregada) {
      _ultimaPropriedadeCarregada = propriedadesVM.idPropriedadeSelecionada;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        talhoesVM.carregarTalhoes(_ultimaPropriedadeCarregada!);
      });
    } else if (propriedadesVM.idPropriedadeSelecionada == null && _ultimaPropriedadeCarregada != null) {
      _ultimaPropriedadeCarregada = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        talhoesVM.limparDados();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _buildBody(propriedadesVM, context),
      ),
    );
  }

  Widget _buildBody(PropriedadesUsuarioViewModel propriedadesVM, BuildContext context) {
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
}