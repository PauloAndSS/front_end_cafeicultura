import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/tratos_culturais_do_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/detalhes_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/relatorio_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/filtro_status_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/relatorio_talhao_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/seletor_tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_encerrar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';

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

  final _atividadesViewModel = TratosCulturaisDoTalhaoViewModel();

  final _relatorioViewModel = RelatorioTalhaoViewModel();

  static const int _abaAtividades = 0;
  static const int _abaRelatorio = 1;

  late final TabController _abas = TabController(
    length: 2,
    initialIndex: _abaAtividades,
    vsync: this,
  );

  bool _relatorioSolicitado = false;

  TipoAtividade _tipoAtividade = TipoAtividade.tratosCulturais;

  @override
  void initState() {
    super.initState();

    _abas.addListener(_aoTrocarAba);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregarRelatorio();
    });
  }

  bool _onScroll(ScrollNotification notificacao) {
    final metrica = notificacao.metrics;

    if (metrica.axis != Axis.vertical) return false;
    if (!atividadeImplementada(_tipoAtividade)) return false;
    if (_atividadesViewModel.mensagemErro != null) return false;

    if (metrica.pixels >= metrica.maxScrollExtent - _margemParaProximaPagina) {
      _atividadesViewModel.carregarMaisPagina();
    }

    return false;
  }

  void _carregarTipoSelecionado() {
    switch (_tipoAtividade) {
      case TipoAtividade.tratosCulturais:
        _carregarAtividades();
      case TipoAtividade.colheitas:
      case TipoAtividade.preSecagens:
      case TipoAtividade.despolpagens:
      case TipoAtividade.fermentacoes:
      case TipoAtividade.secagens:
      case TipoAtividade.pilagens:
        break;
    }
  }

  void _carregarAtividades() {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (idPropriedade == null || idTalhao == null) return;

    _atividadesViewModel.carregar(idPropriedade, idTalhao);
  }

  void _carregarRelatorio() {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (idPropriedade == null || idTalhao == null) return;

    final safraVM = context.read<SafraViewModel>();

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
          talhao: widget.talhao,
        ),
      ),
    );

    if (alterou == true && mounted) {
      context.read<AtividadesMudaram>().invalidar();
      _relatorioViewModel.recarregar();
    }
  }

  void _onSucesso(String mensagem) {
    mostrarSucesso(context, mensagem);

    Navigator.of(context).pop(true);
  }

  Future<void> _confirmarEncerramento() async {
    final dataFimEscolhida = await selecionarData(
      context: context,
      ajuda: 'Selecione a data de encerramento do talhão',
      minima: widget.talhao.dataInicio,
    );

    if (dataFimEscolhida == null) return;
    if (!mounted) return;

    final confirmar = await confirmarAcao(
      context,
      titulo: 'Encerrar talhão?',
      mensagem:
          'Deseja encerrar o talhão "${widget.talhao.nomeExibicao}" '
          'na data ${formatarDataBr(dataFimEscolhida)}?',
      rotuloConfirmar: 'Encerrar talhão',
      corConfirmar: AppCores.avisoTexto,
      complemento: const CaixaAvisoAtencao(
        mensagem: 'O talhão sai da lista de Ativos e passa a aparecer na aba '
            'Encerrados, com todo o histórico preservado. Você não poderá '
            'mais registrar nem alterar atividades nele, e o aplicativo não '
            'oferece como reativá-lo.',
      ),
    );

    if (confirmar) {
      final sucesso = await _viewModel.encerrar(
        widget.talhao.id!,
        dataFimEscolhida,
      );

      if (!mounted) return;

      if (sucesso == true) {
        _onSucesso('Talhão encerrado. Ele agora está na aba "Encerrados".');
      } else {
        mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao encerrar talhão.');
      }
    }
  }

  Future<void> _excluir() async {
    final sucesso = await _viewModel.excluir(widget.talhao.id!);

    if (!mounted) return;

    if (sucesso == true) {
      _onSucesso('Talhão excluído com sucesso!');
    } else {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao excluir talhão.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool estaEncerrado = widget.talhao.encerrado;

    final geracaoDoCache = context.watch<AtividadesMudaram>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _atividadesViewModel.sincronizarCom(geracaoDoCache);
    });

    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBarPadrao(titulo: widget.talhao.nomeExibicao),
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
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _CabecalhoAbas(
                abasPadrao(
                  controller: _abas,
                  abas: const [
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

  Widget _construirCabecalhoTalhao(bool estaEncerrado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CartaoDetalhe(
          titulo: 'Informações do Talhão',
          selo: estaEncerrado
              ? const BadgeTexto(texto: 'Encerrado', cor: Colors.red)
              : null,
          conteudo: [
            LinhaInfo(
              rotulo: 'Nome:',
              valor: widget.talhao.nomeExibicao,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            LinhaInfo(
              rotulo: 'Espécie:',
              valor: widget.talhao.especieFormatada,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            LinhaInfo(
              rotulo: 'Variedades de Café:',
              valor: widget.talhao.variedadesTexto,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            LinhaInfo(
              rotulo: 'Quantidade de Pés:',
              valor: widget.talhao.qtdPeCafeFormatada,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            LinhaInfo(
              rotulo: 'Tamanho:',
              valor: widget.talhao.tamanhoFormatado,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            LinhaInfo(
              rotulo: 'Data de Início:',
              valor: widget.talhao.dataInicioFormatada,
              padding: EdgeInsets.zero,
            ),
            if (widget.talhao.dataFimFormatada != null) ...[
              const SizedBox(height: 12),
              LinhaInfo(
                rotulo: 'Data de Encerramento:',
                valor: widget.talhao.dataFimFormatada!,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        if (estaEncerrado) ...[
          const CaixaAviso(
            icone: Icons.info_outline,
            cor: Colors.orange,
            corDoTexto: Colors.brown,
            mensagem: 'Este talhão está encerrado. Não é possível '
                'registrar atividades nem alterá-lo — apenas '
                'visualizar.',
          ),
          const SizedBox(height: 8),
        ],

        const Divider(color: AppCores.borda),

        Row(
          children: [
            if (!estaEncerrado)
              BotaoEncerrar(
                rotulo: 'Encerrar talhão',
                carregando: _viewModel.isLoading,
                aoTocar: _confirmarEncerramento,
              ),
            Expanded(
              child: BotaoExcluir(
                titulo: 'Excluir Talhão?',
                mensagem:
                    'Tem certeza que deseja excluir permanentemente o '
                    'talhão "${widget.talhao.nomeExibicao}"? '
                    'Esta ação não poderá ser desfeita.',
                bloqueado: _viewModel.isLoading,
                aoConfirmar: _excluir,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _construirAbaAtividades() {
    return Builder(
      builder: (context) => NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
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
                builder: (context, child) => _construirSecaoRelatorio(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSecaoRelatorio(BuildContext context) {
    final safraVM = context.watch<SafraViewModel>();
    final idPropriedade = context
        .watch<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    if (idPropriedade == null) {
      return _construirCaixaAviso(
        'Selecione uma propriedade para ver o relatório.',
      );
    }

    if (safraVM.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppCores.verdePrimario)),
      );
    }

    if (safraVM.safras.isEmpty) {
      return _construirCaixaAviso('Nenhuma safra cadastrada nesta propriedade.');
    }

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
            onSelecionar: _atividadesViewModel.selecionarStatus,
          ),
        ),
      ],
    );
  }

  Widget _construirSliverAtividades() {
    if (!atividadeImplementada(_tipoAtividade)) {
      return SliverToBoxAdapter(child: _construirTipoEmDesenvolvimento());
    }

    if (_atividadesViewModel.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppCores.verdePrimario),
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

  Widget _construirErroAtividades(String mensagem) {
    return MensagemDeErro(
      mensagem: mensagem,
      aoTentarNovamente: _atividadesViewModel.tentarNovamente,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    );
  }

  Widget _construirRodapeAtividades() {
    return RodapePaginacao(
      carregando: _atividadesViewModel.isCarregandoMais,
      mensagemErro: _atividadesViewModel.mensagemErro,
      aoTentarNovamente: _atividadesViewModel.tentarNovamente,
    );
  }

  Widget _construirTipoEmDesenvolvimento() {
    return _construirCaixaAviso('${_tipoAtividade.rotulo} em desenvolvimento.');
  }

  Widget _construirAtividadesVazias() {
    final statusTexto = switch (_atividadesViewModel.statusAtual) {
      StatusEvento.agendado => ' agendada',
      StatusEvento.emAndamento => ' em andamento',
      StatusEvento.finalizado => ' finalizada',
    };

    return _construirCaixaAviso(
      'Nenhuma atividade$statusTexto neste talhão.',
    );
  }

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
}

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
