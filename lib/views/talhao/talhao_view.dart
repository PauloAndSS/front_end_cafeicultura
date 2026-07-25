// lib/views/eventos/talhao_view.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/talhao_card.dart';
import 'package:provider/provider.dart';

enum StatusTalhaoFiltro { ativos, encerrados }

class TalhaoView extends StatefulWidget {
  const TalhaoView({super.key});

  @override
  State<TalhaoView> createState() => _TalhaoViewState();
}

class _TalhaoViewState extends State<TalhaoView> {
  StatusTalhaoFiltro _filtroSelecionado = StatusTalhaoFiltro.ativos;
  int? _ultimoIdPropriedade;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada != null &&
        propriedadesVM.idPropriedadeSelecionada != _ultimoIdPropriedade) {
      _ultimoIdPropriedade = propriedadesVM.idPropriedadeSelecionada;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        talhoesVM.carregarTalhoes(_ultimoIdPropriedade!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.watch<TalhoesViewModel>();

    String nomePropriedade = 'esta propriedade';
    if (propriedadesVM.idPropriedadeSelecionada != null && propriedadesVM.propriedades.isNotEmpty) {
      final prop = propriedadesVM.propriedades.firstWhere(
        (p) => p.id == propriedadesVM.idPropriedadeSelecionada,
        orElse: () => propriedadesVM.propriedades.first,
      );
      nomePropriedade = prop.nome;
    }

    final talhoesFiltrados = _filtroSelecionado == StatusTalhaoFiltro.ativos
        ? talhoesVM.talhoesAtivos
        : talhoesVM.talhoesEncerrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (propriedadesVM.idPropriedadeSelecionada == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecione uma propriedade primeiro.')),
            );
            return;
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarTalhaoView(),
            ),
          );
        },
        backgroundColor: const Color(0xFF67835C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Talhão', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<StatusTalhaoFiltro>(
                  segments: const [
                    ButtonSegment<StatusTalhaoFiltro>(
                      value: StatusTalhaoFiltro.ativos,
                      label: Text('Ativos'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                    ButtonSegment<StatusTalhaoFiltro>(
                      value: StatusTalhaoFiltro.encerrados,
                      label: Text('Encerrados'),
                      icon: Icon(Icons.archive_outlined),
                    ),
                  ],
                  selected: {_filtroSelecionado},
                  onSelectionChanged: (Set<StatusTalhaoFiltro> novaSelecao) {
                    setState(() {
                      _filtroSelecionado = novaSelecao.first;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF67835C);
                      }
                      return Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black87;
                    }),
                  ),
                ),
              ),
            ),
            // Conteúdo principal (Lista ou mensagens de vazio/erro)
            Expanded(
              child: _buildBody(talhoesVM, talhoesFiltrados, nomePropriedade),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TalhoesViewModel vm, List talhoesFiltrados, String nomePropriedade) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF67835C)));
    }

    if (vm.mensagemErro != null) {
      return Center(
        child: Text(
          vm.mensagemErro!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (talhoesFiltrados.isEmpty) {
      final statusTexto = _filtroSelecionado == StatusTalhaoFiltro.ativos ? 'ativos' : 'encerrados';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Você não tem talhões $statusTexto na propriedade "$nomePropriedade".',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 80.0),
      itemCount: talhoesFiltrados.length,
      itemBuilder: (context, index) {
        final talhao = talhoesFiltrados[index];
    
        return TalhaoCard(
          talhao: talhao,
        );
      },
    );
  }
}