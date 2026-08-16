import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
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

const _verdePrimario = Color(0xFF67835C);

const _margemParaProximaPagina = 300.0;

class ListaAtividadesView<T extends EventoAgricola> extends StatefulWidget {
  /// Listagem paginada por status.
  final ListaAtividadesDaPropriedadePaginadaViewModel<T> viewModel;

  /// Calendário mensal — cache próprio, por mês.
  final AgendaMensalViewModel<T> agendaViewModel;

  final String rotuloCadastrar;

  final String Function(StatusEvento status, String nomePropriedade)
      construirMensagemVazia;

  final IconData iconeCard;

  final Widget Function(BuildContext context, DateTime? dataInicial)
      construirTelaCadastro;

  final Widget Function(BuildContext context, T atividade, String nomeTalhao)
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
    extends State<ListaAtividadesView<T>> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma propriedade primeiro.')),
      );
      return;
    }

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => widget.construirTelaCadastro(context, dataInicial),
      ),
    );

    if (cadastrou == true && mounted) _recarregar();
  }

  Future<void> _abrirDetalhes(T atividade) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => widget.construirTelaDetalhes(
          context,
          atividade,
          _viewModel.nomeDoTalhao(atividade.idTalhao),
        ),
      ),
    );

    if (alterou == true && mounted) _recarregar();
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
    // O dia aceso é do mês que acabou de sair de vista.
    setState(() => _diaSelecionado = null);

    final idPropriedade = _idPropriedadeDaAgenda;
    if (idPropriedade == null) return;

    _agendaViewModel.carregarMes(idPropriedade, mes);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: _verdePrimario,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.rotuloCadastrar,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          // Os dois ViewModels desenham partes diferentes da mesma tela.
          listenable: Listenable.merge([_viewModel, _agendaViewModel]),
          builder: (context, _) {
            return _construirCorpo(_nomeDaPropriedade(propriedadesVM));
          },
        ),
      ),
    );
  }

  Widget _construirCorpo(String nomePropriedade) {
    return RefreshIndicator(
      color: _verdePrimario,
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
          child: CircularProgressIndicator(color: _verdePrimario),
        ),
      ),
    );
  }

  Widget _construirErroDaListagem(String mensagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
      child: Column(
        children: [
          Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _viewModel.tentarNovamente,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: _verdePrimario),
            ),
          ),
        ],
      ),
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
      child: Column(
        children: [
          Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _agendaViewModel.recarregarMesVisivel,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: _verdePrimario),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirRodapeDaLista() {
    if (_viewModel.isCarregandoMais) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _verdePrimario,
            ),
          ),
        ),
      );
    }

    final erro = _viewModel.mensagemErro;

    if (erro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              erro,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _viewModel.tentarNovamente,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: _verdePrimario),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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

  String _nomeDaPropriedade(PropriedadesUsuarioViewModel propriedadesVM) {
    if (propriedadesVM.idPropriedadeSelecionada == null ||
        propriedadesVM.propriedades.isEmpty) {
      return 'esta propriedade';
    }

    final propriedade = propriedadesVM.propriedades.firstWhere(
      (propriedade) =>
          propriedade.id == propriedadesVM.idPropriedadeSelecionada,
      orElse: () => propriedadesVM.propriedades.first,
    );

    return propriedade.nome;
  }
}
