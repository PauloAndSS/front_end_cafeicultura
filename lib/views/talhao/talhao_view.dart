import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/detalhes_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/talhao_card.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

enum StatusTalhaoFiltro { ativos, encerrados }

class TalhaoView extends StatefulWidget {
  const TalhaoView({super.key});

  @override
  State<TalhaoView> createState() => _TalhaoViewState();
}

class _TalhaoViewState extends State<TalhaoView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StatusTalhaoFiltro _filtroSelecionado = StatusTalhaoFiltro.ativos;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final talhoesVM = context.read<TalhoesViewModel>();
      if (talhoesVM.temMaisPaginas && !talhoesVM.isLoadingMais) {
        talhoesVM.carregarMaisTalhoes();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada != null &&
        propriedadesVM.idPropriedadeSelecionada !=
            talhoesVM.idPropriedadeAtual) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        talhoesVM.carregarTalhoes(propriedadesVM.idPropriedadeSelecionada!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.watch<TalhoesViewModel>();

    final nomePropriedade = propriedadesVM.nomeDaPropriedadeSelecionada;

    final talhoesFiltrados = _filtroSelecionado == StatusTalhaoFiltro.ativos
        ? talhoesVM.talhoesAtivos
        : talhoesVM.talhoesEncerrados;

    return Scaffold(
      backgroundColor: AppCores.fundo,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (propriedadesVM.idPropriedadeSelecionada == null) {
            mostrarAviso(context, 'Selecione uma propriedade primeiro.');
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarTalhaoView(),
            ),
          );
        },
        backgroundColor: AppCores.verdePrimario,
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
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      estados,
                    ) {
                      if (estados.contains(WidgetState.selected)) {
                        return AppCores.verdePrimario;
                      }
                      return Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      estados,
                    ) {
                      if (estados.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black87;
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildBody(talhoesVM, talhoesFiltrados, nomePropriedade),
            ),
          ],
        ),
      ),
    );
  }

  bool _temRodape(TalhoesViewModel vm) =>
      vm.isLoadingMais || vm.mensagemErro != null;

  Widget _construirRodape(TalhoesViewModel vm) {
    return RodapePaginacao(
      carregando: vm.isLoadingMais,
      mensagemErro: vm.mensagemErro,
      aoTentarNovamente: vm.carregarMaisTalhoes,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    );
  }

  Widget _buildBody(
    TalhoesViewModel vm,
    List talhoesFiltrados,
    String nomePropriedade,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.verdePrimario),
      );
    }

    if (vm.mensagemErro != null && talhoesFiltrados.isEmpty) {
      return Center(
        child: Text(
          vm.mensagemErro!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (talhoesFiltrados.isEmpty) {
      final statusTexto = _filtroSelecionado == StatusTalhaoFiltro.ativos
          ? 'ativos'
          : 'encerrados';
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
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 80.0,
      ),
      itemCount: talhoesFiltrados.length + (_temRodape(vm) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == talhoesFiltrados.length) {
          return _construirRodape(vm);
        }

        final talhao = talhoesFiltrados[index];
        return TalhaoCard(
          talhao: talhao,
          onTap: () async {
            final alterou = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesTalhaoView(talhao: talhao),
              ),
            );

            if (alterou == true && context.mounted) {
              final propriedadesVM = context
                  .read<PropriedadesUsuarioViewModel>();
              if (propriedadesVM.idPropriedadeSelecionada != null) {
                context.read<TalhoesViewModel>().carregarTalhoes(
                  propriedadesVM.idPropriedadeSelecionada!,
                );
              }
            }
          },
        );
      },
    );
  }
}
