import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/agenda_mensal_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_paginada_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividades_do_dia_sheet.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/filtro_status_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/calendario/calendario_atividades.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/reinicio_de_secao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

const _margemParaProximaPagina = 300.0;

class ListaAtividadesView<T extends EventoAgricola> extends StatefulWidget {
  final ListaAtividadesDaPropriedadePaginadaViewModel<T> viewModel;

  final AgendaMensalViewModel<T> agendaViewModel;

  final String rotuloCadastrar;

  final String Function(StatusEvento status, String nomePropriedade)
      construirMensagemVazia;

  final IconData iconeCard;

  final Widget Function(BuildContext context, DateTime? dataInicial)
      construirTelaCadastro;

  final Widget Function(BuildContext context, T atividade, Talhao? talhao)
      construirTelaDetalhes;

  const ListaAtividadesView({
    super.key,
    required this.viewModel,
    required this.agendaViewModel,
    required this.rotuloCadastrar,
    required this.construirMensagemVazia,
    required this.iconeCard,
    required this.construirTelaCadastro,
    required this.construirTelaDetalhes,
  });

  @override
  State<ListaAtividadesView<T>> createState() => _ListaAtividadesViewState<T>();
}

class _ListaAtividadesViewState<T extends EventoAgricola>
    extends State<ListaAtividadesView<T>>
    with AutomaticKeepAliveClientMixin, ReinicioDeSecaoMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  SecaoPrincipal get secaoDoReinicio => SecaoPrincipal.atividades;

  @override
  void aoReiniciarSecao() {
    voltarAoTopo(_controladorDeRolagem);
  }

  final _controladorDeRolagem = ScrollController();

  DateTime? _diaSelecionado;

  int? _idPropriedadeDaAgenda;

  ListaAtividadesDaPropriedadePaginadaViewModel<T> get _viewModel =>
      widget.viewModel;
  AgendaMensalViewModel<T> get _agendaViewModel => widget.agendaViewModel;

  @override
  void initState() {
    super.initState();
    _controladorDeRolagem.addListener(_aoRolar);
  }

  @override
  void dispose() {
    _controladorDeRolagem.removeListener(_aoRolar);
    _controladorDeRolagem.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVM.idPropriedadeSelecionada;

    if (idPropriedade == null) return;

    final trocouDePropriedade =
        _idPropriedadeDaAgenda != null && _idPropriedadeDaAgenda != idPropriedade;
    final precisaCarregarAgenda = _idPropriedadeDaAgenda != idPropriedade;

    _idPropriedadeDaAgenda = idPropriedade;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (trocouDePropriedade) _agendaViewModel.limparCache();

      _viewModel.carregar(idPropriedade);
      if (precisaCarregarAgenda) {
        _agendaViewModel.carregarMes(idPropriedade, hoje());
      }
    });
  }

  void _aoRolar() {
    if (!_controladorDeRolagem.hasClients) return;

    if (_viewModel.mensagemErro != null) return;

    final posicao = _controladorDeRolagem.position;

    if (posicao.pixels >= posicao.maxScrollExtent - _margemParaProximaPagina) {
      _viewModel.carregarMaisPagina();
    }
  }

  Future<void> _abrirCadastro({DateTime? dataInicial}) async {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada == null) {
      mostrarAviso(context, 'Selecione uma propriedade primeiro.');
      return;
    }

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => widget.construirTelaCadastro(context, dataInicial),
      ),
    );

    if (cadastrou == true && mounted) {
      context.read<AtividadesMudaram>().invalidar();
    }
  }

  Future<void> _abrirDetalhes(T atividade) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => widget.construirTelaDetalhes(
          context,
          atividade,
          _viewModel.talhaoPorId(atividade.idTalhao),
        ),
      ),
    );

    if (alterou == true && mounted) {
      context.read<AtividadesMudaram>().invalidar();
    }
  }

  Future<void> _recarregar() {
    return Future.wait([
      _viewModel.recarregar(),
      _agendaViewModel.recarregarMesVisivel(),
    ]);
  }

  void _abrirAtividadesDoDia(DateTime dia, List<T> doDia) {
    setState(() => _diaSelecionado = dia);

    mostrarAtividadesDoDia<T>(
      context: context,
      dia: dia,
      atividades: doDia,
      nomeDoTalhao: _agendaViewModel.nomeDoTalhao,
      aoTocar: _abrirDetalhes,
      rotuloCadastrar: widget.rotuloCadastrar,
      aoCadastrar: () => _abrirCadastro(dataInicial: dia),
    );
  }

  void _mudarMes(DateTime mes) {
    setState(() => _diaSelecionado = null);

    final idPropriedade = _idPropriedadeDaAgenda;
    if (idPropriedade == null) return;

    _agendaViewModel.carregarMes(idPropriedade, mes);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    observarReinicioDeSecao(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();

    final geracaoDoCache = context.watch<AtividadesMudaram>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.sincronizarCom(geracaoDoCache);
      _agendaViewModel.sincronizarCom(geracaoDoCache);
    });

    return Scaffold(
      backgroundColor: AppCores.fundo,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: AppCores.verdePrimario,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.rotuloCadastrar,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _agendaViewModel]),
          builder: (context, _) {
            return _construirCorpo(propriedadesVM.nomeDaPropriedadeSelecionada);
          },
        ),
      ),
    );
  }

  Widget _construirCorpo(String nomePropriedade) {
    return RefreshIndicator(
      color: AppCores.verdePrimario,
      onRefresh: _recarregar,
      child: CustomScrollView(
        controller: _controladorDeRolagem,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _construirCalendario(),
                  const SizedBox(height: 24),
                  FiltroStatusAtividade(
                    selecionado: _viewModel.statusAtual,
                    onSelecionar: _viewModel.selecionarStatus,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
            sliver: _construirSliverDaListagem(nomePropriedade),
          ),
        ],
      ),
    );
  }
    Widget _construirSliverDaListagem(String nomePropriedade) {
    if (_viewModel.isLoading) return _construirCarregandoListagem();

    final atividades = _viewModel.atividades;

    if (atividades.isEmpty) {
      final erro = _viewModel.mensagemErro;

      return SliverToBoxAdapter(
        child: erro != null
            ? _construirErroDaListagem(erro)
            : _construirListaVazia(nomePropriedade),
      );
    }
    return SliverList.builder(
      itemCount: atividades.length + 1,
      itemBuilder: (context, indice) => indice < atividades.length
          ? _construirCard(atividades[indice])
          : _construirRodapeDaLista(),
    );
  }
  Widget _construirCarregandoListagem() {
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: AppCores.verdePrimario),
        ),
      ),
    );
  }

  Widget _construirErroDaListagem(String mensagem) {
    return MensagemDeErro(
      mensagem: mensagem,
      aoTentarNovamente: _viewModel.tentarNovamente,
    );
  }

  Widget _construirCalendario() {
    final erro = _agendaViewModel.mensagemErro;

    if (erro != null) return _construirErroDoCalendario(erro);

    return CalendarioAtividades<T>(
      atividades: _agendaViewModel.atividadesDoMes,
      mesInicial: _agendaViewModel.mesVisivel,
      diaSelecionado: _diaSelecionado,
      carregando: _agendaViewModel.isLoading,
      corDoMarcador: (atividade) => corDoStatus(atividade.status),
      aoMudarMes: _mudarMes,
      aoSelecionarDia: _abrirAtividadesDoDia,
    );
  }

  Widget _construirErroDoCalendario(String mensagem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: MensagemDeErro(
        mensagem: mensagem,
        aoTentarNovamente: _agendaViewModel.recarregarMesVisivel,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _construirRodapeDaLista() {
    return RodapePaginacao(
      carregando: _viewModel.isCarregandoMais,
      mensagemErro: _viewModel.mensagemErro,
      aoTentarNovamente: _viewModel.tentarNovamente,
    );
  }

  Widget _construirCard(T atividade) {
    return AtividadeCard(
      atividade: atividade,
      nomeTalhao: _viewModel.nomeDoTalhao(atividade.idTalhao),
      icone: widget.iconeCard,
      onTap: () => _abrirDetalhes(atividade),
    );
  }

  Widget _construirListaVazia(String nomePropriedade) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
      child: Text(
        widget.construirMensagemVazia(_viewModel.statusAtual, nomePropriedade),
        style: const TextStyle(fontSize: 16, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }

}
