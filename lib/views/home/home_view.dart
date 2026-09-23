import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/agenda_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/clima/weather_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/cotacao_cafe_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividades_do_dia_sheet.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/widgets/cotacao_cafe_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/widgets/weather_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_tipo_atividade_sheet.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/widgets/resumo_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/acoes_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/calendario/calendario_atividades.dart';
import 'package:provider/provider.dart';

import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_relatorio.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/financeiro/financeiro_mudou.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/reinicio_de_secao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/retorno_a_secao.dart';
import 'package:frond_end_cafeicultura_mobile/views/safra/acoes_safra.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/acoes_propriedade.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        ReinicioDeSecaoMixin,
        RetornoASecaoMixin {
  final _agendaViewModel = AgendaPropriedadeViewModel();
  final _cotacaoCafeViewModel = CotacaoCafeViewModel();
  final _weatherViewModel = WeatherViewModel();
  int? _idPropriedadeDaAgenda;

  late final TabController _abas;
  final _rolagemVisaoGeral = ScrollController();
  final _rolagemSafra = ScrollController();

  DateTime? _diaSelecionadoNaAgenda;

  @override
  bool get wantKeepAlive => true;

  @override
  SecaoPrincipal get secaoDoReinicio => SecaoPrincipal.home;

  @override
  void aoReiniciarSecao() {
    _abas.index = 0;
    voltarAoTopo(_rolagemVisaoGeral);
    voltarAoTopo(_rolagemSafra);
    _voltarAoMesAtual();
  }

  @override
  SecaoPrincipal get secaoDoRetorno => SecaoPrincipal.home;

  @override
  void aoRetornarASecao() => _voltarAoMesAtual();

  void _voltarAoMesAtual() {
    final idPropriedade = _idPropriedadeDaAgenda;
    if (idPropriedade == null) return;

    if (_diaSelecionadoNaAgenda != null) {
      setState(() => _diaSelecionadoNaAgenda = null);
    }

    _agendaViewModel.carregarMes(idPropriedade, hoje());
  }

  @override
  void initState() {
    super.initState();
    _abas = TabController(length: 2, vsync: this);
    _cotacaoCafeViewModel.carregar();
  }

  @override
  void dispose() {
    _abas.dispose();
    _rolagemVisaoGeral.dispose();
    _rolagemSafra.dispose();
    _agendaViewModel.dispose();
    _cotacaoCafeViewModel.dispose();
    _weatherViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    observarReinicioDeSecao(context);
    observarRetornoASecao(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final talhoesVM = context.read<TalhoesViewModel>();

    final geracaoDoCache = context.watch<AtividadesMudaram>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _agendaViewModel.sincronizarCom(geracaoDoCache);
    });

    final safraVM = context.read<SafraViewModel>();

    // Sincroniza o relatório financeiro exibido na aba Safra sempre que uma
    // despesa é cadastrada ou excluída em outra tela (ex: FinanceiroView).
    final geracaoFinanceiro = context.watch<FinanceiroMudou>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safraVM.sincronizarComFinanceiro(geracaoFinanceiro);
    });

    if (propriedadesVM.idPropriedadeSelecionada != null) {
      final idPropriedade = propriedadesVM.idPropriedadeSelecionada!;

      if (idPropriedade != talhoesVM.idPropriedadeAtual) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          talhoesVM.carregarTalhoes(idPropriedade);
        });
      }

      if (_safraAindaNaoCarregadaPara(safraVM, idPropriedade) &&
          !safraVM.isLoading) {
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

    return Scaffold(
      backgroundColor: AppCores.fundo,
      body: SafeArea(
        child: Column(
          children: [
            BarraDeAbas(
              controller: _abas,
              abas: const [
                Tab(text: 'Visão Geral'),
                Tab(text: 'Safra'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _abas,
                children: [
                  _buildVisaoGeralTab(propriedadesVM),
                  _buildSafraTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaoGeralTab(PropriedadesUsuarioViewModel propriedadesVM) {
    if (propriedadesVM.isLoading && propriedadesVM.propriedades.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final propriedade = propriedadesVM.propriedadeSelecionada;

    if (propriedadesVM.propriedades.isNotEmpty && propriedade == null) {
      return const EstadoPropriedadeNaoSelecionada(
        mensagem: 'Selecione uma propriedade no seletor do topo da tela.',
      );
    }

    return _construirPaginaVisaoGeral(propriedade);
  }

  Widget _construirPaginaVisaoGeral(Propriedade? propriedade) {
    return RefreshIndicator(
      color: AppCores.acao,
      onRefresh: () => _recarregarVisaoGeral(propriedade),
      child: SingleChildScrollView(
        controller: _rolagemVisaoGeral,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirTopoDaVisaoGeral(propriedade),
            const SizedBox(height: 24),
            ChangeNotifierProvider.value(
              value: _weatherViewModel,
              child: const WeatherWidget(),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: _cotacaoCafeViewModel,
              builder: (context, _) =>
                  CotacaoCafeWidget(viewModel: _cotacaoCafeViewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTopoDaVisaoGeral(Propriedade? propriedade) {
    if (propriedade == null) return const CartaoSemPropriedade();

    return _construirBlocoDaPropriedade(propriedade);
  }

  Widget _construirBlocoDaPropriedade(Propriedade propriedade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResumoPropriedade(propriedade: propriedade),
        const SizedBox(height: 24),
        const Text(
          'Atividades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppCores.acao,
          ),
        ),
        const SizedBox(height: 12),
        _construirSecaoAtividades(propriedade.id!),
      ],
    );
  }

  bool _safraAindaNaoCarregadaPara(SafraViewModel safraVM, int idPropriedade) {
    return safraVM.propriedadeIdAtual != idPropriedade ||
        !safraVM.dadosCarregados;
  }

  bool _talhoesAindaNaoCarregadosPara(
    TalhoesViewModel talhoesVM,
    int idPropriedade,
  ) {
    return talhoesVM.idPropriedadeAtual != idPropriedade ||
        (talhoesVM.isLoading && talhoesVM.talhoes.isEmpty);
  }

  Widget _construirSecaoAtividades(int idPropriedade) {
    return Consumer2<TalhoesViewModel, SafraViewModel>(
      builder: (context, talhoesVM, safraVM, child) {
        if (_talhoesAindaNaoCarregadosPara(talhoesVM, idPropriedade) ||
            _safraAindaNaoCarregadaPara(safraVM, idPropriedade)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final erro =
            (talhoesVM.talhoes.isEmpty ? talhoesVM.mensagemErro : null) ??
            (safraVM.safras.isEmpty ? safraVM.mensagemErro : null);

        if (erro != null) {
          return MensagemDeErro(
            mensagem: erro,
            aoTentarNovamente: () => _recarregarPendencias(idPropriedade),
          );
        }

        final pendencias = <Widget>[
          if (talhoesVM.talhoes.isEmpty) const AvisoSemTalhao(),
          if (!safraVM.temSafraAberta) const AvisoSemSafraAberta(),
        ];

        if (pendencias.isNotEmpty) return _construirPendencias(pendencias);

        return _construirCalendario(idPropriedade);
      },
    );
  }

  Widget _construirPendencias(List<Widget> pendencias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < pendencias.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          pendencias[i],
        ],
      ],
    );
  }

  Widget _construirCalendario(int? idPropriedade) {
    return ListenableBuilder(
      listenable: _agendaViewModel,
      builder: (context, _) {
        return CorpoComEstado(
          isLoading:
              _agendaViewModel.isLoading && !_agendaViewModel.carregouAlgumaVez,
          mensagemErro: _agendaViewModel.mensagemErro,
          aoTentarNovamente: () => _agendaViewModel.recarregarMesVisivel(),
          vazio: false,
          construirVazio: (_) => const SizedBox.shrink(),
          construirConteudo: (_) => CalendarioAtividades<EventoAgricola>(
            atividades: _agendaViewModel.atividadesDoMes,
            mesInicial: _agendaViewModel.mesVisivel,
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
    }
  }

  Future<void> _abrirDetalhes(EventoAgricola atividade) async {
    if (atividade is! TratoCultural) {
      mostrarInfo(
        context,
        'Os detalhes desta atividade ainda não estão disponíveis.',
      );
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
    }
  }

  Future<void> _recarregarVisaoGeral(Propriedade? propriedade) {
    final comuns = [
      _weatherViewModel.carregarPrevisao(propriedade, forcar: true),
      _cotacaoCafeViewModel.carregar(),
    ];

    final idPropriedade = propriedade?.id;
    if (idPropriedade == null) return Future.wait(comuns);

    return Future.wait([
      ...comuns,
      _agendaViewModel.recarregarMesVisivel(),
      _recarregarPendencias(idPropriedade),
    ]);
  }

  Future<void> _recarregarPendencias(int idPropriedade) {
    return Future.wait([
      context.read<TalhoesViewModel>().carregarTalhoes(idPropriedade),
      context.read<SafraViewModel>().carregarDadosDaPropriedade(
        idPropriedade,
        forcarAtualizacao: true,
      ),
    ]);
  }

  Future<void> _recarregarSafra() async {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    if (idPropriedade == null) return;

    await context.read<SafraViewModel>().carregarDadosDaPropriedade(
      idPropriedade,
      forcarAtualizacao: true,
    );
  }

  Widget _buildSafraTab(BuildContext context) {
    final safraVM = context.watch<SafraViewModel>();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();

    if (propriedadesVM.propriedades.isEmpty) {
      return const EstadoSemPropriedade();
    }

    if (safraVM.isLoading && safraVM.safras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _recarregarSafra,
      child: SingleChildScrollView(
        controller: _rolagemSafra,
        physics: const AlwaysScrollableScrollPhysics(),
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
              mostrarAcoes: true,
              isLoading: safraVM.isLoading,
              onNovaSafra: () => abrirNovaSafra(context),
              onEncerrarSafra: () => encerrarSafraSelecionada(context),
              onReativarSafra: () => reativarSafraSelecionada(context),
            ),

            const SizedBox(height: 16),

            if (safraVM.mensagemErro != null && safraVM.safras.isEmpty) ...[
              CartaoDeErro(mensagem: safraVM.mensagemErro!),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _recarregarSafra,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ),
            ] else if (safraVM.safras.isEmpty) ...[
              const CartaoVazio(
                icone: Icons.grass,
                mensagem:
                    'Nenhuma safra cadastrada para esta propriedade. '
                    'Crie a primeira para começar a registrar o ciclo.',
              ),
            ] else ...[
              ListenableBuilder(
                listenable: _agendaViewModel,
                builder: (context, _) => SafraRelatorioWidget(
                  eventos: safraVM.relatorio,
                  relatorioFinanceiro: safraVM.relatorioFinanceiro,
                  isLoading: safraVM.isLoadingRelatorio,
                  mostrarTitulo: false,
                  idPropriedade: safraVM.propriedadeIdAtual,
                  idSafra: safraVM.safraSelecionada?.id,
                  nomeDoTalhao: _agendaViewModel.nomeDoTalhao,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
