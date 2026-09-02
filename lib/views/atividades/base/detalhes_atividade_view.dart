import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/periodo.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/confirmar_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/secoes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

typedef ConstrutorBlocosAtividade<T> = List<Widget> Function(
  BuildContext context,
  T atividade,
  bool editavel,
);

class DetalhesAtividadeView<T extends EventoAgricola>
    extends StatefulWidget {
  final DetalhesAtividadeViewModel<T> viewModel;
  final Talhao? talhao;

  final String tituloCartao;

  final String rotuloBotaoConfirmar;

  final String tituloTelaConfirmar;

  final String ajudaDataInicio;
  final String ajudaDataFim;

  final String mensagemSucessoConfirmar;
  final String mensagemJaFinalizada;

  final ConstrutorBlocosAtividade<T>? construirLinhasExtras;

  final ConstrutorBlocosAtividade<T>? construirSecoesExtras;

  final SecaoVaziaAtividade<T>? secaoExtraVazia;

  final ConstrutorSecaoAtividade<T>? construirSecaoExtraNaConfirmacao;

  const DetalhesAtividadeView({
    super.key,
    required this.viewModel,
    required this.talhao,
    required this.tituloCartao,
    required this.rotuloBotaoConfirmar,
    required this.tituloTelaConfirmar,
    required this.ajudaDataInicio,
    required this.ajudaDataFim,
    required this.mensagemSucessoConfirmar,
    required this.mensagemJaFinalizada,
    this.construirLinhasExtras,
    this.construirSecoesExtras,
    this.secaoExtraVazia,
    this.construirSecaoExtraNaConfirmacao,
  });

  @override
  State<DetalhesAtividadeView<T>> createState() =>
      _DetalhesAtividadeViewState<T>();
}

class _DetalhesAtividadeViewState<T extends EventoAgricola>
    extends State<DetalhesAtividadeView<T>> {
  DetalhesAtividadeViewModel<T> get _viewModel => widget.viewModel;

  String get _nomeTalhao =>
      widget.talhao?.nomeExibicao ?? 'Talhão #${_viewModel.atividade.idTalhao}';

  Periodo? _janelaDoLancamento() {
    final safra =
        context.read<SafraViewModel>().safraPorId(_viewModel.atividade.idSafra);

    final periodoTalhao = widget.talhao?.periodo;
    final periodoSafra = safra?.periodo;

    if (periodoTalhao == null) return periodoSafra;
    if (periodoSafra == null) return periodoTalhao;

    return periodoTalhao.intersecao(periodoSafra);
  }

  Future<void> _abrirConfirmacao() async {
    final confirmou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmarAtividadeView<T>(
          viewModel: _viewModel,
          talhao: widget.talhao,
          titulo: widget.tituloTelaConfirmar,
          ajudaDataInicio: widget.ajudaDataInicio,
          ajudaDataFim: widget.ajudaDataFim,
          secaoExtraVazia: widget.secaoExtraVazia,
          construirSecaoExtra: widget.construirSecaoExtraNaConfirmacao,
        ),
      ),
    );

    if (confirmou == true && mounted) {
      mostrarSucesso(context, widget.mensagemSucessoConfirmar);
    }
  }

  Future<void> _alterarDataInicio() async {
    final atual = apenasData(_viewModel.atividade.dataInicio);

    final janela = _janelaDoLancamento();

    final escolhida = await selecionarData(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: atual,
      minima: janela?.inicio,
      maxima: menorData(limiteAgendamento, janela?.fim),
    );

    if (escolhida == null || !mounted) return;
    if (apenasData(escolhida) == atual) return;

    final sucesso = await _viewModel.alterarDataInicio(escolhida);

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Data de início alterada com sucesso!');
    } else {
      mostrarErro(
        context,
        _viewModel.mensagemErro ?? 'Erro ao alterar a data de início.',
      );
    }
  }

  Future<void> _alterarDescricao() async {
    final novaDescricao = await showDialog<String>(
      context: context,
      builder: (_) => _AlterarDescricaoDialog(
        descricaoAtual: _viewModel.atividade.descricao ?? '',
      ),
    );

    if (novaDescricao == null || !mounted) return;

    final sucesso = await _viewModel.alterarDescricao(novaDescricao);

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Descrição alterada com sucesso!');
    } else {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao alterar a descrição.');
    }
  }

  String get _motivoDespesaSomenteLeitura {
    if (_viewModel.atividade.finalizado) {
      return 'A atividade está finalizada: as despesas dela viraram histórico '
          'e não podem mais ser excluídas.';
    }

    return 'Aguarde a conclusão da operação em andamento para alterar as '
        'despesas.';
  }

  Future<void> _excluir() async {
    final sucesso = await _viewModel.excluir();

    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao excluir a atividade.');
      return;
    }

    mostrarSucesso(context, 'Atividade excluída com sucesso!');

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_viewModel.houveAlteracao);
      },
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(
          tituloWidget: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Text(_viewModel.atividade.tituloExibicao),
          ),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirCartaoInformacoes(context),
                  const SizedBox(height: 32),
                  _construirRodape(),
                  _construirAcaoExcluir(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirCartaoInformacoes(BuildContext context) {
    final atividade = _viewModel.atividade;

    final safra = context.watch<SafraViewModel>().safraPorId(atividade.idSafra);

    final editavel = !atividade.finalizado && !_viewModel.isLoading;

    return CartaoDetalhe(
      titulo: widget.tituloCartao,
      selo: BadgeStatusAtividade(atividade: atividade),
      transparente: true,
      corDivisor: AppCores.borda,
      conteudo: [
        ...?widget.construirLinhasExtras?.call(
          context,
          atividade,
          editavel,
        ),
        LinhaInfo(rotulo: 'Talhão:', valor: _nomeTalhao),
        if (safra != null)
          LinhaInfo(
            rotulo: 'Safra:',
            valor: safra.nomeComSituacao,
          ),
        LinhaInfo(
          rotulo: 'Descrição:',
          valor: atividade.descricaoTexto,
          onEditar: editavel && _viewModel.podeAlterarDescricao
              ? _alterarDescricao
              : null,
        ),
        LinhaInfo(
          rotulo: 'Data de Início:',
          valor: atividade.dataInicioFormatada,
          onEditar: editavel && _viewModel.podeAlterarDataInicio
              ? _alterarDataInicio
              : null,
        ),
        LinhaInfo(
          rotulo: 'Data de Término:',
          valor: atividade.dataFimFormatada ?? 'Em aberto',
        ),
        if (atividade.dataCadastroFormatada != null)
          LinhaInfo(
            rotulo: 'Cadastrado em:',
            valor: atividade.dataCadastroFormatada!,
          ),
        const Divider(height: 32, color: AppCores.borda),
        SecaoResponsaveisAtividade<T>(
          viewModel: _viewModel,
          podeEditar: editavel,
        ),
        const Divider(height: 32, color: AppCores.borda),
        SecaoDespesasAtividade<T>(
          viewModel: _viewModel,
          podeEditar: editavel,
          motivoSomenteLeitura: _motivoDespesaSomenteLeitura,
        ),
        ...?widget.construirSecoesExtras?.call(
          context,
          atividade,
          editavel,
        ),
      ],
    );
  }

  Widget _construirRodape() {
    final atividade = _viewModel.atividade;

    return switch (atividade.status) {
      StatusEvento.agendado => AvisoAtividadeAgendada(
          dataInicioFormatada: atividade.dataInicioFormatada,
        ),
      StatusEvento.finalizado => AvisoAtividadeFinalizada(
          mensagem: widget.mensagemJaFinalizada,
        ),
      StatusEvento.emAndamento => _construirBotaoConfirmar(),
    };
  }

  Widget _construirBotaoConfirmar() {
    if (!_viewModel.podeConfirmar) return const SizedBox.shrink();

    final bloqueado = _viewModel.isLoading;

    return CustomButton(
      text: bloqueado ? 'Aguarde...' : widget.rotuloBotaoConfirmar,
      onPressed: bloqueado ? null : _abrirConfirmacao,
    );
  }

  Widget _construirAcaoExcluir() {
    if (!_viewModel.podeExcluir) return const SizedBox.shrink();

    return BotaoExcluir(
      titulo: 'Excluir atividade?',
      mensagem:
          'Deseja realmente excluir "${_viewModel.atividade.tituloExibicao}"? '
          'Esta ação não poderá ser desfeita.',
      bloqueado: _viewModel.isLoading,
      aoConfirmar: _excluir,
    );
  }
}

class _AlterarDescricaoDialog extends StatefulWidget {
  final String descricaoAtual;

  const _AlterarDescricaoDialog({required this.descricaoAtual});

  @override
  State<_AlterarDescricaoDialog> createState() =>
      _AlterarDescricaoDialogState();
}

class _AlterarDescricaoDialogState extends State<_AlterarDescricaoDialog> {
  late final _controller = TextEditingController(text: widget.descricaoAtual);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar Descrição'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'O que foi feito no talhão',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppCores.borda),
          ),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: 'Salvar',
        aoConfirmar: () => Navigator.of(context).pop(_controller.text),
      ),
    );
  }
}
