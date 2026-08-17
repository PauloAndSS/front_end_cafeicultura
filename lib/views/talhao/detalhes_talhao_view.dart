// lib/views/talhao/detalhes_talhao_view.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/tratos_culturais_do_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/detalhes_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/relatorio_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/filtro_status_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/relatorio_talhao_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/seletor_tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:provider/provider.dart';

/// Distância do fim da rolagem em que a próxima página já é pedida — a mesma
/// da aba de atividades, para as duas telas paginarem com a mesma folga.
const _margemParaProximaPagina = 300.0;

class DetalhesTalhaoView extends StatefulWidget {
  final Talhao talhao;

  const DetalhesTalhaoView({super.key, required this.talhao});

  @override
  State<DetalhesTalhaoView> createState() => _DetalhesTalhaoViewState();
}

class _DetalhesTalhaoViewState extends State<DetalhesTalhaoView>
    with SingleTickerProviderStateMixin {
  final _viewModel = DetalhesTalhaoViewModel();

  /// ViewModel próprio para as atividades: o `isLoading` de [_viewModel] já
  /// desabilita os botões de encerrar/excluir, e recarregar a lista não pode
  /// bloquear essas ações.
  final _atividadesViewModel = TratosCulturaisDoTalhaoViewModel();

  /// Terceiro ViewModel, pelo mesmo motivo do segundo: o relatório é uma
  /// requisição independente da lista de atividades, e um `isLoading`
  /// compartilhado faria o spinner de um esconder o conteúdo do outro.
  final _relatorioViewModel = RelatorioTalhaoViewModel();

  static const int _abaAtividades = 0;
  static const int _abaRelatorio = 1;

  /// `TabController` próprio, e não o `DefaultTabController` que a Home e a aba
  /// de atividades usam: a carga sob demanda do relatório precisa de um
  /// listener de troca de aba, e pedir o controller herdado dentro do mesmo
  /// `build` que o cria seria acesso circular.
  late final TabController _abas = TabController(
    length: 2,
    initialIndex: _abaAtividades,
    vsync: this,
  );

  /// O relatório é buscado no primeiro toque na aba, não na abertura da tela:
  /// quem abre o talhão para lançar ou conferir uma atividade nunca paga a
  /// requisição do relatório, que é a mais cara das duas.
  bool _relatorioSolicitado = false;

  TipoAtividade _tipoAtividade = TipoAtividade.tratosCulturais;

  @override
  void initState() {
    super.initState();

    _abas.addListener(_aoTrocarAba);

    // carregar notifica de forma síncrona: chamar aqui direto dispararia
    // rebuild no meio do primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAtividades();
    });
  }

  @override
  void dispose() {
    _abas.removeListener(_aoTrocarAba);
    _abas.dispose();
    _atividadesViewModel.dispose();
    _relatorioViewModel.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _aoTrocarAba() {
    if (_abas.index != _abaRelatorio || _relatorioSolicitado) return;

    _relatorioSolicitado = true;

    // O listener dispara do ticker da animação da aba, que pode estar no meio
    // de um layout, e `carregarDadosDaPropriedade` notifica de forma síncrona.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregarRelatorio();
    });
  }

  /// Pede a próxima página quando a rolagem da aba de atividades se aproxima
  /// do fim.
  ///
  /// Notificação, e não `ScrollController`: dentro do corpo de um
  /// [NestedScrollView] quem manda no scrollable interno é o
  /// `PrimaryScrollController` injetado por ele — passar um controller próprio
  /// desconectaria o cabeçalho da rolagem das abas.
  ///
  /// Retorna sempre `false`. O [NestedScrollView] depende de as notificações
  /// continuarem subindo para coordenar cabeçalho e corpo; consumir aqui
  /// travaria a rolagem da tela inteira.
  ///
  /// As duas guardas extras importam: um tipo de atividade sem tela
  /// implementada não tem o que paginar, e um erro pendente espera o botão em
  /// vez de retentar a cada pixel rolado.
  bool _aoRolar(ScrollNotification notificacao) {
    final metrica = notificacao.metrics;

    if (metrica.axis != Axis.vertical) return false;
    if (!atividadeImplementada(_tipoAtividade)) return false;
    if (_atividadesViewModel.mensagemErro != null) return false;

    if (metrica.pixels >= metrica.maxScrollExtent - _margemParaProximaPagina) {
      _atividadesViewModel.carregarMaisPagina();
    }

    return false;
  }

  /// Gancho de extensão do select: cada tipo novo entra como um `case`. Os
  /// ainda não implementados não disparam requisição — é o que mantém a
  /// abertura da tela barata.
  void _carregarTipoSelecionado({bool forcar = false}) {
    switch (_tipoAtividade) {
      case TipoAtividade.tratosCulturais:
        _carregarAtividades(forcar: forcar);
      case TipoAtividade.colheitas:
      case TipoAtividade.preSecagens:
      case TipoAtividade.despolpagens:
      case TipoAtividade.fermentacoes:
      case TipoAtividade.secagens:
      case TipoAtividade.pilagens:
        break;
    }
  }

  void _carregarAtividades({bool forcar = false}) {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (idPropriedade == null || idTalhao == null) return;

    _atividadesViewModel.carregar(idPropriedade, idTalhao, forcar: forcar);
  }

  /// Primeira carga do relatório, na safra de trabalho do usuário.
  ///
  /// A lista de safras vem do [SafraViewModel] global, mas a seleção daqui em
  /// diante é do [_relatorioViewModel]: trocar a safra deste relatório não
  /// pode mudar em que safra o próximo trato cultural será cadastrado.
  void _carregarRelatorio() {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (idPropriedade == null || idTalhao == null) return;

    final safraVM = context.read<SafraViewModel>();

    // Chegando aqui sem passar pela Home, a lista de safras pode nunca ter
    // sido buscada. O cache de sessão do ViewModel absorve a chamada extra
    // quando ela já foi feita.
    if (!safraVM.dadosCarregados || safraVM.propriedadeIdAtual != idPropriedade) {
      safraVM.carregarDadosDaPropriedade(idPropriedade);
      return;
    }

    _selecionarSafraDoRelatorio(safraVM.safraSelecionada);
  }

  void _selecionarSafraDoRelatorio(Safra? safra) {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (safra == null || idPropriedade == null || idTalhao == null) return;

    _relatorioViewModel.selecionarSafra(
      safra,
      idPropriedade: idPropriedade,
      idTalhao: idTalhao,
    );
  }

  Future<void> _abrirDetalhesTrato(TratoCultural trato) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesTratoCulturalView(
          trato: trato,
          nomeTalhao: widget.talhao.nomeExibicao,
        ),
      ),
    );

    // forcar: o trato pode ter sido finalizado ou editado lá dentro, então o
    // cache está velho.
    // O relatório vai junto: um trato confirmado lá dentro muda a contagem de
    // "Em andamento"/"Finalizados", e deixar só a lista atualizar deixaria as
    // duas abas discordando uma da outra. Se a aba do relatório nunca foi
    // aberta, `recarregar` sai cedo por não haver safra selecionada — o no-op
    // é intencional, e é o que preserva a carga sob demanda.
    if (alterou == true && mounted) {
      _carregarAtividades(forcar: true);
      _relatorioViewModel.recarregar();
    }
  }

  void _onSucesso(String mensagem) {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    if (propriedadesVM.idPropriedadeSelecionada != null) {
      context.read<TalhoesViewModel>().carregarTalhoes(
        propriedadesVM.idPropriedadeSelecionada!,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _onErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Sem parâmetro de contexto: o `context` do State é o mesmo que o `mounted`
  /// daqui protege. Recebê-lo de fora fazia o guard proteger um contexto e o
  /// diálogo usar outro.
  Future<void> _confirmarEncerramento() async {
    final DateTime hoje = DateTime.now();

    final DateTime? dataFimEscolhida = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: widget.talhao.dataInicio,
      lastDate: hoje,
      helpText: 'Selecione a data de encerramento do talhão',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF67835C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataFimEscolhida == null) return;
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Encerrar Talhão'),
        // A consequência vem junto da pergunta, e não depois dela: encerrar
        // parece reversível pelo nome, e não é — o talhão vira somente leitura.
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja realmente encerrar o talhão "${widget.talhao.nomeExibicao}" '
              'na data ${formatarDataBr(dataFimEscolhida)}?',
            ),
            const SizedBox(height: 16),
            const CaixaAvisoAtencao(
              mensagem: 'Depois de encerrado, você não poderá mais registrar '
                  'atividades nem fazer alterações neste talhão — apenas '
                  'visualizá-lo.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Encerrar',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _viewModel.encerrar(
        widget.talhao.id!,
        dataFimEscolhida,
      );

      if (!mounted) return;

      if (sucesso == true) {
        _onSucesso('Talhão encerrado com sucesso!');
      } else {
        _onErro(_viewModel.mensagemErro ?? 'Erro ao encerrar talhão.');
      }
    }
  }

  /// Chamado pelo [BotaoExcluir] depois que o usuário confirma no diálogo.
  ///
  /// O erro mantém a tela aberta de propósito: a recusa mais comum é o 403 de
  /// "há atividades cadastradas nele", e é aqui que o usuário vê a lista que
  /// precisa limpar antes de tentar de novo.
  Future<void> _excluir() async {
    final sucesso = await _viewModel.excluir(widget.talhao.id!);

    if (!mounted) return;

    if (sucesso == true) {
      _onSucesso('Talhão excluído com sucesso!');
    } else {
      _onErro(_viewModel.mensagemErro ?? 'Erro ao excluir talhão.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool estaEncerrado = widget.talhao.dataFim != null || widget.talhao.arquivado == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.talhao.nomeExibicao,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF67835C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // NestedScrollView: o cadastro do talhão e suas ações são cabeçalho —
      // rolam junto e saem de vista —, enquanto a TabBar gruda no topo e cada
      // aba mantém a própria rolagem. Antes eram três blocos empilhados numa
      // rolagem só, e chegar ao primeiro card de atividade custava passar pelo
      // dashboard inteiro.
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) =>
                    _construirCabecalhoTalhao(estaEncerrado),
              ),
            ),
          ),
          // O absorber é o par obrigatório do injector das abas: sem ele o topo
          // do conteúdo de cada aba fica escondido atrás da TabBar fixa.
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _CabecalhoAbas(
                TabBar(
                  controller: _abas,
                  labelColor: const Color(0xFF67835C),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF67835C),
                  indicatorWeight: 3.0,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Atividades'),
                    Tab(text: 'Relatório'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _abas,
          children: [
            _construirAbaAtividades(),
            _construirAbaRelatorio(),
          ],
        ),
      ),
    );
  }

  /// Cadastro do talhão e as duas ações destrutivas — o que rola e sai de vista
  /// acima das abas.
  Widget _construirCabecalhoTalhao(bool estaEncerrado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informações do Talhão',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF67835C),
                    ),
                  ),
                  if (estaEncerrado)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Encerrado',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow('Nome:', widget.talhao.nomeExibicao),
              const SizedBox(height: 12),
              _buildInfoRow('Espécie:', widget.talhao.especieFormatada),
              const SizedBox(height: 12),
              _buildInfoRow('Variedades de Café:', widget.talhao.variedadesTexto),
              const SizedBox(height: 12),
              _buildInfoRow('Quantidade de Pés:', widget.talhao.qtdPeCafeFormatada),
              const SizedBox(height: 12),
              _buildInfoRow('Tamanho:', widget.talhao.tamanhoFormatado),
              const SizedBox(height: 12),
              _buildInfoRow('Data de Início:', widget.talhao.dataInicioFormatada),
              if (widget.talhao.dataFimFormatada != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Data de Encerramento:', widget.talhao.dataFimFormatada!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),

        if (estaEncerrado)
          const CaixaAviso(
            icone: Icons.info_outline,
            cor: Colors.orange,
            corDoTexto: Colors.brown,
            mensagem: 'Este talhão está encerrado. Não é possível '
                'registrar atividades nem alterá-lo — apenas '
                'visualizar.',
          )
        else
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _viewModel.isLoading
                  ? 'Encerrando...'
                  : 'Encerrar Talhão',
              onPressed: _viewModel.isLoading
                  ? null
                  : _confirmarEncerramento,
            ),
          ),

        // Discreto e abaixo do encerrar: excluir apaga o talhão e o histórico
        // junto, e não é o que o usuário veio fazer aqui. Com dois botões de
        // largura total, a ação irreversível tinha o mesmo peso da reversível.
        BotaoExcluir(
          titulo: 'Excluir Talhão?',
          mensagem:
              'Tem certeza que deseja excluir permanentemente o '
              'talhão "${widget.talhao.nomeExibicao}"? '
              'Esta ação não poderá ser desfeita.',
          bloqueado: _viewModel.isLoading,
          aoConfirmar: _excluir,
        ),
      ],
    );
  }

  /// Aba da esquerda: o registro atividade a atividade, com rolagem infinita.
  ///
  /// O [Builder] existe para o [SliverOverlapInjector] achar o handle — ele só
  /// é visível a partir de um contexto abaixo do [NestedScrollView], e o
  /// contexto do `build` do State está acima. A [PageStorageKey] guarda a
  /// posição da rolagem, que o [TabBarView] descartaria ao reconstruir a aba.
  Widget _construirAbaAtividades() {
    return Builder(
      builder: (context) => NotificationListener<ScrollNotification>(
        onNotification: _aoRolar,
        child: CustomScrollView(
          key: const PageStorageKey('atividades'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: _atividadesViewModel,
                  builder: (context, child) => _construirCabecalhoAtividades(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              sliver: ListenableBuilder(
                listenable: _atividadesViewModel,
                builder: (context, child) => _construirSliverAtividades(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aba da direita: os mesmos eventos, agregados.
  Widget _construirAbaRelatorio() {
    return Builder(
      builder: (context) => CustomScrollView(
        key: const PageStorageKey('relatorio'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: _relatorioViewModel,
                builder: (context, child) => _construirSecaoRelatorio(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Relatório agregado do talhão na safra escolhida.
  ///
  /// Sem título próprio: o rótulo da aba logo acima já diz o que é isto, e
  /// repeti-lo só empurraria o seletor para baixo.
  Widget _construirSecaoRelatorio() {
    final safraVM = context.watch<SafraViewModel>();
    final idPropriedade = context
        .watch<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    // Caixa neutra, e não `SizedBox.shrink()`: como aba inteira, sumir deixaria
    // uma tela em branco que se lê como falha de carregamento.
    if (idPropriedade == null) {
      return _construirCaixaAviso(
        'Selecione uma propriedade para ver o relatório.',
      );
    }

    if (safraVM.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF67835C))),
      );
    }

    if (safraVM.safras.isEmpty) {
      return _construirCaixaAviso('Nenhuma safra cadastrada nesta propriedade.');
    }

    // As safras podem ter chegado depois do toque na aba — foi o próprio
    // `_carregarRelatorio` que pediu a lista. Este é o ponto em que a resposta
    // vira a primeira seleção; sem ele o relatório ficaria esperando um toque
    // no dropdown que o usuário não tem motivo para dar.
    if (_relatorioViewModel.safraSelecionada == null && safraVM.safraSelecionada != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selecionarSafraDoRelatorio(safraVM.safraSelecionada);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafraSelectorWidget(
          safras: safraVM.safras,
          safraSelecionada: _relatorioViewModel.safraSelecionada,
          mostrarAcoes: false,
          isLoading: _relatorioViewModel.isLoading,
          onSelecionar: _selecionarSafraDoRelatorio,
        ),
        const SizedBox(height: 12),
        RelatorioTalhaoWidget(
          eventos: _relatorioViewModel.eventos,
          isLoading: _relatorioViewModel.isLoading,
          mensagemErro: _relatorioViewModel.mensagemErro,
          onTentarNovamente: _relatorioViewModel.recarregar,
        ),
      ],
    );
  }

  /// Seletor de tipo e segmentado de status, sem título — quem nomeia a seção
  /// agora é a aba.
  ///
  /// O filtro vai ao servidor: em vez de guardar a seleção num campo do State e
  /// repartir uma lista já baixada, ele delega ao ViewModel, que mantém uma
  /// página por status. `null` é o segmento "Todas".
  Widget _construirCabecalhoAtividades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeletorTipoAtividade(
          selecionado: _tipoAtividade,
          onSelecionar: (novoTipo) {
            setState(() {
              _tipoAtividade = novoTipo;
            });
            _carregarTipoSelecionado();
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FiltroStatusAtividade(
            selecionado: _atividadesViewModel.statusAtual,
            filtros: _atividadesViewModel.filtros,
            onSelecionar: _atividadesViewModel.selecionarStatus,
          ),
        ),
      ],
    );
  }

  Widget _construirSliverAtividades() {
    // Antes da cascata de estado: sem esta guarda, o spinner e o erro dos
    // tratos culturais vazariam para os tipos ainda não implementados.
    if (!atividadeImplementada(_tipoAtividade)) {
      return SliverToBoxAdapter(child: _construirTipoEmDesenvolvimento());
    }

    if (_atividadesViewModel.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF67835C)),
          ),
        ),
      );
    }

    final atividades = _atividadesViewModel.atividades;

    if (atividades.isEmpty) {
      final erro = _atividadesViewModel.mensagemErro;

      return SliverToBoxAdapter(
        child: erro != null
            ? _construirErroAtividades(erro)
            : _construirAtividadesVazias(),
      );
    }

    // O item extra é o rodapé: indicador da próxima página, ou o erro dela.
    return SliverList.builder(
      itemCount: atividades.length + 1,
      itemBuilder: (context, indice) => indice < atividades.length
          ? AtividadeCard(
              atividade: atividades[indice],
              nomeTalhao: widget.talhao.nomeExibicao,
              icone: Icons.grass,
              onTap: () => _abrirDetalhesTrato(atividades[indice]),
            )
          : _construirRodapeAtividades(),
    );
  }

  /// Erro com a lista vazia — ocupa o lugar dos cards.
  ///
  /// O botão é obrigatório, e não enfeite: o ViewModel paginado não retenta
  /// sozinho depois de uma falha (buscar de novo a cada rebuild transformaria
  /// uma rota fora do ar numa requisição por frame), então sem ele a seção
  /// ficaria travada no erro até o usuário sair da tela e voltar.
  Widget _construirErroAtividades(String mensagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _atividadesViewModel.tentarNovamente,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: Color(0xFF67835C)),
            ),
          ),
        ],
      ),
    );
  }

  /// Rodapé da lista: o que a rolagem infinita tem a dizer sem arrancar os
  /// cards já visíveis da tela.
  Widget _construirRodapeAtividades() {
    if (_atividadesViewModel.isCarregandoMais) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF67835C),
            ),
          ),
        ),
      );
    }

    final erro = _atividadesViewModel.mensagemErro;

    if (erro != null) return _construirErroAtividades(erro);

    return const SizedBox.shrink();
  }

  Widget _construirTipoEmDesenvolvimento() {
    return _construirCaixaAviso('${_tipoAtividade.rotulo} em desenvolvimento.');
  }

  Widget _construirAtividadesVazias() {
    // No segmento "Todas" não há adjetivo a acrescentar: a frase é sobre o
    // talhão inteiro, não sobre um recorte dele.
    final statusTexto = switch (_atividadesViewModel.statusAtual) {
      StatusEvento.agendado => ' agendada',
      StatusEvento.emAndamento => ' em andamento',
      StatusEvento.finalizado => ' finalizada',
      null => '',
    };

    return _construirCaixaAviso(
      'Nenhuma atividade$statusTexto neste talhão.',
    );
  }

  /// Caixa neutra usada tanto para lista vazia quanto para tipo ainda não
  /// implementado ou aba de relatório sem recorte possível — mesma moldura, só
  /// muda o texto.
  Widget _construirCaixaAviso(String mensagem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          mensagem,
          style: const TextStyle(fontSize: 14, color: Colors.black45),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// A [TabBar] fixada no topo do corpo, entre o cabeçalho que rola e a aba.
///
/// O fundo branco é obrigatório: o header fica pinado sobre o `0xFFF5F5F5` da
/// tela e, sem ele, os cards passariam por baixo dos rótulos ao rolar.
class _CabecalhoAbas extends SliverPersistentHeaderDelegate {
  final TabBar abas;

  const _CabecalhoAbas(this.abas);

  @override
  double get minExtent => abas.preferredSize.height;

  @override
  double get maxExtent => abas.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: Colors.white, child: abas);
  }

  @override
  bool shouldRebuild(_CabecalhoAbas oldDelegate) => oldDelegate.abas != abas;
}
