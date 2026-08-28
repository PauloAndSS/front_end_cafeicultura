import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/detalhes_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/notificacoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/confirmar_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/editar_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/notificacoes/widgets/notificacao_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:provider/provider.dart';

class NotificacoesView extends StatefulWidget {
  const NotificacoesView({super.key});

  @override
  State<NotificacoesView> createState() => _NotificacoesViewState();
}

class _NotificacoesViewState extends State<NotificacoesView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _prepararTela());
  }

  Future<void> _prepararTela() async {
    if (!mounted) return;

    final viewModel = context.read<NotificacoesViewModel>();
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    if (idPropriedade != null) await viewModel.garantirCarregado(idPropriedade);

    if (!mounted) return;

    await viewModel.marcarLidasSemAcaoPendente();
  }

  Future<bool> _marcarComoLida(NotificacaoAgrupada grupo) async {
    final viewModel = context.read<NotificacoesViewModel>();
    final sucesso = await viewModel.marcarComoLida(grupo);

    if (!mounted) return sucesso;

    if (!sucesso) {
      mostrarErro(
        context,
        viewModel.mensagemErroLeitura ??
            'Não foi possível marcar a notificação como lida.',
      );
    }

    return sucesso;
  }

  Future<void> _marcarTodas() async {
    final viewModel = context.read<NotificacoesViewModel>();
    final sucesso = await viewModel.marcarTodasComoLidas();

    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(
        context,
        viewModel.mensagemErroLeitura ??
            'Não foi possível marcar as notificações como lidas.',
      );
      return;
    }

    mostrarSucesso(context, 'Notificações marcadas como lidas.');
  }

  Future<void> _abrirDetalhes(TratoCultural trato) async {
    final viewModel = context.read<NotificacoesViewModel>();

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalhesTratoCulturalView(
          trato: trato,
          talhao: viewModel.talhaoPorId(trato.idTalhao),
        ),
      ),
    );

    if (!mounted) return;

    context.read<AtividadesMudaram>().invalidar();
  }

  Future<void> _responderSim(
    NotificacaoAgrupada grupo,
    TratoCultural trato,
  ) async {
    final viewModel = context.read<NotificacoesViewModel>();
    final detalhes = DetalhesTratoCulturalViewModel(trato);

    final confirmado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ConfirmarAtividadeView<TratoCultural>(
          viewModel: detalhes,
          talhao: viewModel.talhaoPorId(trato.idTalhao),
          titulo: 'Confirmar Trato Cultural',
          ajudaDataInicio: 'Data de início do trato cultural',
          ajudaDataFim: 'Data de término do trato cultural',
        ),
      ),
    );

    detalhes.dispose();

    if (!mounted || confirmado != true) return;

    mostrarSucesso(context, 'Trato cultural confirmado com sucesso!');
    context.read<AtividadesMudaram>().invalidar();
  }

  Future<void> _alterarInformacoes(
    NotificacaoAgrupada grupo,
    TratoCultural trato,
  ) async {
    final viewModel = context.read<NotificacoesViewModel>();

    final alterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditarTratoCulturalView(trato: trato)),
    );

    if (!mounted || alterado != true) return;

    context.read<AtividadesMudaram>().invalidar();
    viewModel.aposEdicao(grupo);
  }

  Future<void> _excluirTrato(
    NotificacaoAgrupada grupo,
    TratoCultural trato,
  ) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Excluir trato cultural?',
      mensagem:
          'O trato ${trato.tituloExibicao} será excluído definitivamente, '
          'junto com as despesas e os insumos lançados nele.',
      rotuloConfirmar: 'Excluir',
    );

    if (!confirmou || !mounted) return;

    final viewModel = context.read<NotificacoesViewModel>();
    final sucesso = await viewModel.excluirAtividade(grupo);

    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(
        context,
        viewModel.mensagemErro ?? 'Erro ao excluir o trato cultural.',
      );
      return;
    }

    mostrarSucesso(context, 'Trato cultural excluído com sucesso!');
    context.read<AtividadesMudaram>().invalidar();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificacoesViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(
          titulo: 'Notificações',
          acoes: [
            TextButton(
              onPressed: viewModel.temNaoLidas ? _marcarTodas : null,
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(
                  color: viewModel.temNaoLidas ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            BarraDeAbas(
              abas: [
                Tab(text: 'Não lidas (${viewModel.quantidadeNaoLidas})'),
                Tab(text: 'Lidas (${viewModel.lidas.length})'),
              ],
            ),
            Expanded(
              child: CorpoComEstado(
                isLoading: viewModel.isLoading,
                mensagemErro: viewModel.vazio ? viewModel.mensagemErro : null,
                vazio: false,
                construirVazio: (_) => const SizedBox.shrink(),
                construirConteudo: (_) => TabBarView(
                  children: [
                    _construirAba(
                      viewModel: viewModel,
                      secoes: viewModel.secoesNaoLidas,
                      podeDispensar: true,
                      mensagemVazia:
                          'Nenhuma notificação pendente. Os lembretes das '
                          'atividades aparecem aqui.',
                      iconeVazio: Icons.notifications_off_outlined,
                    ),
                    _construirAba(
                      viewModel: viewModel,
                      secoes: viewModel.secoesLidas,
                      podeDispensar: false,
                      mensagemVazia:
                          'Nenhuma notificação lida ainda. Deslize um card da '
                          'aba anterior para marcá-lo como lido.',
                      iconeVazio: Icons.done_all,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirAba({
    required NotificacoesViewModel viewModel,
    required List<SecaoDeNotificacoes> secoes,
    required bool podeDispensar,
    required String mensagemVazia,
    required IconData iconeVazio,
  }) {
    return RefreshIndicator(
      color: AppCores.verdePrimario,
      onRefresh: viewModel.recarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: secoes.isEmpty
            ? [
                const SizedBox(height: 100),
                EstadoVazio(mensagem: mensagemVazia, icone: iconeVazio),
              ]
            : [
                if (podeDispensar) ...[
                  const CaixaAviso(
                    icone: Icons.swipe,
                    cor: AppCores.verdePrimario,
                    corDoTexto: AppCores.verdePrimario,
                    mensagem: 'Deslize um card para o lado para marcá-lo como '
                        'lido.',
                  ),
                  const SizedBox(height: 20),
                ],
                for (final secao in secoes)
                  ..._construirSecao(viewModel, secao, podeDispensar),
              ],
      ),
    );
  }

  List<Widget> _construirSecao(
    NotificacoesViewModel viewModel,
    SecaoDeNotificacoes secao,
    bool podeDispensar,
  ) {
    return [
      _CabecalhoDeSecao(titulo: secao.titulo, quantidade: secao.grupos.length),
      for (final grupo in secao.grupos)
        _construirCard(viewModel, grupo, podeDispensar),
    ];
  }

  Widget _construirCard(
    NotificacoesViewModel viewModel,
    NotificacaoAgrupada grupo,
    bool podeDispensar,
  ) {
    final trato = viewModel.atividadeDe(grupo);

    final card = NotificacaoCard(
      grupo: grupo,
      atividade: trato,
      dataDoEvento: viewModel.dataDoEvento(grupo),
      nomeTalhao: trato == null
          ? 'Talhão não informado'
          : viewModel.nomeDoTalhao(trato.idTalhao),
      confirmada: viewModel.estaConfirmada(grupo),
      aoAbrir: trato == null ? null : () => _abrirDetalhes(trato),
      aoResponderSim: trato == null ? null : () => _responderSim(grupo, trato),
      aoAlterar: trato == null ? null : () => _alterarInformacoes(grupo, trato),
      aoExcluir: trato == null ? null : () => _excluirTrato(grupo, trato),
    );

    if (!podeDispensar) return card;

    return Dismissible(
      key: ValueKey(grupo.representante.chaveDeAgrupamento),
      direction: DismissDirection.horizontal,
      background: const _FundoDeDispensa(alinhamento: Alignment.centerLeft),
      secondaryBackground: const _FundoDeDispensa(
        alinhamento: Alignment.centerRight,
      ),
      confirmDismiss: (_) => _marcarComoLida(grupo),
      child: card,
    );
  }
}

class _CabecalhoDeSecao extends StatelessWidget {
  final String titulo;
  final int quantidade;

  const _CabecalhoDeSecao({required this.titulo, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            '$quantidade',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundoDeDispensa extends StatelessWidget {
  final Alignment alinhamento;

  const _FundoDeDispensa({required this.alinhamento});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alinhamento,
      decoration: BoxDecoration(
        color: AppCores.verdePrimario.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, color: AppCores.verdePrimario),
          SizedBox(width: 8),
          Text(
            'Marcar como lida',
            style: TextStyle(
              color: AppCores.verdePrimario,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
