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

/// Distância do fim da lista em que a próxima página começa a ser buscada.
/// Sobra de cerca de dois cards: pedir só ao encostar no fim mostraria o
/// indicador em toda rolagem.
const _margemParaProximaPagina = 300.0;

/// Aba de um tipo de atividade: calendário do mês no topo, listagem por status
/// embaixo.
///
/// As duas metades são independentes **e têm fontes de dados diferentes**, o que
/// é a razão de esta tela receber dois ViewModels. O calendário é uma visão do
/// tempo: pede à [agendaViewModel] o mês aberto, com a cor do marcador dizendo o
/// status, e o toque num dia abre o painel daquele dia. A listagem é a varredura
/// por status, sem recorte de tempo: o segmentado escolhe o status, o servidor
/// devolve em páginas de 25 e a rolagem pede a seguinte.
///
/// Antes as duas liam a mesma lista em memória. Não dá mais: com o status virando
/// filtro do servidor, "o que está carregado" passou a ser uma fatia de um status
/// só, e o calendário ficaria sem os marcadores dos outros dois.
class ListaAtividadesView<T extends EventoAgricola> extends StatefulWidget {
  /// Listagem paginada por status.
  final ListaAtividadesPaginadaViewModel<T> viewModel;

  /// Calendário mensal — cache próprio, por mês.
  final AgendaMensalViewModel<T> agendaViewModel;

  final String rotuloCadastrar;

  final String Function(StatusEvento status, String nomePropriedade)
      construirMensagemVazia;

  final IconData iconeCard;

  final WidgetBuilder construirTelaCadastro;

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

  /// Dia aceso na grade. Estado só do calendário — a listagem abaixo não o lê.
  DateTime? _diaSelecionado;

  /// Última propriedade para a qual a agenda foi carregada. É o que distingue
  /// "trocou de propriedade" de um rebuild qualquer.
  int? _idPropriedadeDaAgenda;

  ListaAtividadesPaginadaViewModel<T> get _viewModel => widget.viewModel;
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
      // A própria listagem detecta a troca de propriedade e descarta os três
      // status; o calendário precisa que alguém esvazie o cache de meses, que é
      // da propriedade anterior.
      if (trocouDePropriedade) _agendaViewModel.limparCache();

      _viewModel.carregar(idPropriedade);
      if (precisaCarregarAgenda) {
        _agendaViewModel.carregarMes(idPropriedade, hoje());
      }
    });
  }

  /// Pede a próxima página quando a rolagem se aproxima do fim. O ViewModel
  /// ignora a chamada se já estiver buscando ou se não houver mais página, então
  /// o disparo repetido durante o arrasto não vira requisição repetida.
  void _aoRolar() {
    if (!_controladorDeRolagem.hasClients) return;

    // Com erro pendente no rodapé, quem retenta é o botão. Sem esta guarda, uma
    // rota fora do ar viraria uma requisição por quadro de rolagem.
    if (_viewModel.mensagemErro != null) return;

    final posicao = _controladorDeRolagem.position;

    if (posicao.pixels >= posicao.maxScrollExtent - _margemParaProximaPagina) {
      _viewModel.carregarMaisPagina();
    }
  }

  Future<void> _abrirCadastro() async {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma propriedade primeiro.')),
      );
      return;
    }

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: widget.construirTelaCadastro),
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

  /// Recarrega as duas metades. Confirmar uma atividade muda o status dela e a
  /// cor do marcador no mesmo movimento — atualizar só uma deixaria a outra
  /// mentindo.
  Future<void> _recarregar() {
    return Future.wait([
      _viewModel.recarregar(),
      _agendaViewModel.recarregarMesVisivel(),
    ]);
  }

  /// Toque num dia do calendário abre o painel daquele dia — o mesmo da home.
  /// A listagem abaixo fica onde está: quem tocou o dia quis ver o dia, não
  /// refazer o filtro da tela.
  void _abrirAtividadesDoDia(DateTime dia, List<T> doDia) {
    setState(() => _diaSelecionado = dia);

    mostrarAtividadesDoDia<T>(
      context: context,
      dia: dia,
      atividades: doDia,
      nomeDoTalhao: _agendaViewModel.nomeDoTalhao,
      aoTocar: _abrirDetalhes,
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

  /// Sem `CorpoComEstado` aqui, ao contrário das outras telas de atividade:
  /// aquele widget decide carregando/erro/vazio pela tela inteira, e esta tem
  /// duas metades alimentadas por requisições diferentes. Deixá-lo mandando
  /// fazia o toque num segmento apagar o calendário — e o próprio segmentado —
  /// enquanto a primeira página daquele status vinha.
  ///
  /// Cada metade cuida do seu estado: o calendário no cabeçalho da grade
  /// (`CalendarioAtividades.carregando`), a listagem em
  /// [_construirSliverDaListagem].
  Widget _construirCorpo(String nomePropriedade) {
    // Slivers, e não um `SingleChildScrollView` com os cards num `Column`: a
    // lista cresce a cada página e montar todos os cards de uma vez desfaria a
    // preguiça do `SliverList.builder`. O calendário e o filtro rolam junto
    // porque são cabeçalho da mesma tela, não uma barra fixa.
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
            // Folga generosa embaixo: o FAB flutua sobre o fim da lista.
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
            sliver: _construirSliverDaListagem(nomePropriedade),
          ),
        ],
      ),
    );
  }

  /// Cascata de estados **da listagem** — a mesma ordem do `CorpoComEstado`
  /// (carregando → erro → vazio → conteúdo), só que ocupando a região dos cards
  /// em vez da tela.
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

    // Com cards na tela, um erro de página seguinte não chega aqui: vai para o
    // rodapé, sem apagar o que já foi carregado.
    return SliverList.builder(
      // O item extra é o rodapé de "carregando mais".
      itemCount: atividades.length + 1,
      itemBuilder: (context, indice) => indice < atividades.length
          ? _construirCard(atividades[indice])
          : _construirRodapeDaLista(),
    );
  }

  /// Primeira página do status. Altura fixa de propósito: se o bloco encolhesse
  /// para o tamanho do spinner, a rolagem saltaria a cada troca de segmento e
  /// levaria o calendário junto.
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

  /// Erro no lugar dos cards, na mesma moldura do erro do calendário. Retentar
  /// pede só a página que falhou — o calendário acima não é refeito.
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

  /// A grade recebe **todas** as atividades do mês, sem passar pelo filtro de
  /// status: filtrar deixaria todos os marcadores visíveis da mesma cor, e a cor
  /// é justamente o que informa o status ali.
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

  /// Erro do calendário no lugar da grade, e não na tela inteira: a listagem
  /// abaixo vem de outra requisição e pode estar perfeitamente carregada.
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

  /// Rodapé da rolagem infinita: indicador da próxima página ou o erro de quem
  /// falhou ao buscá-la. Ocupa altura zero quando não há nem um nem outro, para
  /// não abrir um vão no fim da lista.
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

    // Com cards na tela, o erro é desta página só — mora no fim da lista, e
    // retentar pede a mesma página de novo em vez de recarregar tudo.
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
