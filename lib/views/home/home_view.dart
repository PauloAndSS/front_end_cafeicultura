import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/agenda_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividades_do_dia_sheet.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_tipo_atividade_sheet.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/widgets/resumo_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/calendario/calendario_atividades.dart';
import 'package:provider/provider.dart';

import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_summary.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_relatorio.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  final _agendaViewModel = AgendaPropriedadeViewModel();

  int? _idPropriedadeDaAgenda;

  DateTime? _diaSelecionadoNaAgenda;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _agendaViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();

    final geracaoDoCache = context.watch<AtividadesMudaram>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _agendaViewModel.sincronizarCom(geracaoDoCache);
    });

    final safraVM = context.read<SafraViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada != null) {
      final idPropriedade = propriedadesVM.idPropriedadeSelecionada!;

      if (idPropriedade != talhoesVM.idPropriedadeAtual) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          talhoesVM.carregarTalhoes(idPropriedade);
        });
      }

      if (idPropriedade != safraVM.propriedadeIdAtual || !safraVM.dadosCarregados) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          safraVM.carregarDadosDaPropriedade(idPropriedade);
        });
      }

      if (idPropriedade != _idPropriedadeDaAgenda) {
        final trocouDePropriedade = _idPropriedadeDaAgenda != null;
        _idPropriedadeDaAgenda = idPropriedade;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (trocouDePropriedade) _agendaViewModel.limparCache();

          _agendaViewModel.carregarMes(idPropriedade, hoje());
        });
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        body: SafeArea(
          child: Column(
            children: [
              const BarraDeAbas(
                rolavel: true,
                abas: [
                  Tab(text: 'Início'),
                  Tab(text: 'Dashboard'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildInicioTab(propriedadesVM, context),
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
      return const Center(child: CircularProgressIndicator(color: AppCores.verdePrimario));
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

    return RefreshIndicator(
      color: AppCores.verdePrimario,
      onRefresh: () => _recarregarTudo(propriedadeSelecionada.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
            const SizedBox(height: 16),

            ResumoPropriedade(propriedade: propriedadeSelecionada),

            const SizedBox(height: 24),

            const Text(
              'Atividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
            const SizedBox(height: 12),

            _construirSecaoAtividades(propriedadeSelecionada.id),
          ],
        ),
      ),
    );
  }

  Widget _construirSecaoAtividades(int? idPropriedade) {
    return Consumer<TalhoesViewModel>(
      builder: (context, talhoesVM, child) {
        if (talhoesVM.isLoading && talhoesVM.talhoes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(color: AppCores.verdePrimario)),
          );
        }

        if (talhoesVM.talhoes.isEmpty) return _construirAtalhoDeTalhao();

        return _construirCalendario(idPropriedade);
      },
    );
  }

  Widget _construirAtalhoDeTalhao() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 64, color: AppCores.verdePrimario),
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
              style: TextStyle(color: AppCores.verdePrimario, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCalendario(int? idPropriedade) {
    return ListenableBuilder(
      listenable: _agendaViewModel,
      builder: (context, _) {
        return CorpoComEstado(
          isLoading: _agendaViewModel.isLoading &&
              !_agendaViewModel.carregouAlgumaVez,
          mensagemErro: _agendaViewModel.mensagemErro,
          aoTentarNovamente: () => _agendaViewModel.recarregarMesVisivel(),
          vazio: false,
          construirVazio: (_) => const SizedBox.shrink(),
          construirConteudo: (_) => CalendarioAtividades<EventoAgricola>(
            atividades: _agendaViewModel.atividadesDoMes,
            diaSelecionado: _diaSelecionadoNaAgenda,
            carregando: _agendaViewModel.isLoading,
            corDoMarcador: (atividade) => corDoStatus(atividade.status),
            aoMudarMes: (mes) {
              setState(() => _diaSelecionadoNaAgenda = null);

              if (idPropriedade == null) return;
              _agendaViewModel.carregarMes(idPropriedade, mes);
            },
            aoSelecionarDia: (dia, doDia) {
              setState(() => _diaSelecionadoNaAgenda = dia);
              _abrirAtividadesDoDia(dia, doDia);
            },
          ),
        );
      },
    );
  }

  Future<void> _abrirAtividadesDoDia(
    DateTime dia,
    List<EventoAgricola> atividades,
  ) {
    return mostrarAtividadesDoDia<EventoAgricola>(
      context: context,
      dia: dia,
      atividades: atividades,
      nomeDoTalhao: _agendaViewModel.nomeDoTalhao,
      aoTocar: _abrirDetalhes,
      rotuloCadastrar: 'Cadastrar atividade',
      aoCadastrar: () => _abrirCadastroDoDia(dia),
    );
  }

  Future<void> _abrirCadastroDoDia(DateTime dia) async {
    if (context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada ==
        null) {
      mostrarAviso(context, 'Selecione uma propriedade primeiro.');
      return;
    }

    final tipo = await mostrarSelecaoTipoAtividade(context: context);

    if (tipo == null || !mounted) return;

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => construirCadastroAtividade(tipo, dia),
      ),
    );

    if (cadastrou == true && mounted) {
      context.read<AtividadesMudaram>().invalidar();
      await _agendaViewModel.recarregarMesVisivel();
    }
  }

  Future<void> _abrirDetalhes(EventoAgricola atividade) async {
    if (atividade is! TratoCultural) {
      mostrarInfo(context, 'Os detalhes desta atividade ainda não estão disponíveis.');
      return;
    }

    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTratoCulturalView(
          trato: atividade,
          talhao: _agendaViewModel.talhaoPorId(atividade.idTalhao),
        ),
      ),
    );

    if (alterou == true && mounted) {
      context.read<AtividadesMudaram>().invalidar();
      await _agendaViewModel.recarregarMesVisivel();
    }
  }

  Future<void> _recarregarTudo(int? idPropriedade) async {
    if (idPropriedade == null) return;

    await Future.wait([
      _agendaViewModel.recarregarMesVisivel(),
      context.read<TalhoesViewModel>().carregarTalhoes(idPropriedade),
    ]);
  }

  Widget _buildDashboardTab(BuildContext context) {
    final safraVM = context.watch<SafraViewModel>();

    if (safraVM.isLoading && safraVM.safras.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppCores.verdePrimario));
    }

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
      color: AppCores.fundo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SafraSelectorWidget(
              safras: safraVM.safras,
              safraSelecionada: safraVM.safraSelecionada,
              onSelecionar: (safra) {
                safraVM.selecionarSafra(safra);
              },
              mostrarAcoes: false,
            ),

            const SizedBox(height: 16),

            if (safraVM.safraSelecionada != null) ...[
              SafraSummaryCard(safra: safraVM.safraSelecionada!),
              const SizedBox(height: 16),
            ],

            ListenableBuilder(
              listenable: _agendaViewModel,
              builder: (context, _) => SafraRelatorioWidget(
                eventos: safraVM.relatorio.cast<EventoAgricola>(),
                isLoading: safraVM.isLoadingRelatorio,
                mostrarTitulo: false,
                nomeDoTalhao: _agendaViewModel.nomeDoTalhao,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
