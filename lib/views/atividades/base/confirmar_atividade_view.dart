import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/periodo.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/secoes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';

typedef SecaoVaziaAtividade<T> = bool Function(T atividade);

typedef ConstrutorSecaoAtividade<T> = Widget Function(
  BuildContext context,
  T atividade,
);

class ConfirmarAtividadeView<T extends EventoAgricola>
    extends StatefulWidget {
  final DetalhesAtividadeViewModel<T> viewModel;

  final Talhao? talhao;

  final String titulo;

  final String ajudaDataInicio;
  final String ajudaDataFim;

  final SecaoVaziaAtividade<T>? secaoExtraVazia;

  final ConstrutorSecaoAtividade<T>? construirSecaoExtra;

  const ConfirmarAtividadeView({
    super.key,
    required this.viewModel,
    required this.talhao,
    required this.titulo,
    required this.ajudaDataInicio,
    required this.ajudaDataFim,
    this.secaoExtraVazia,
    this.construirSecaoExtra,
  });

  @override
  State<ConfirmarAtividadeView<T>> createState() =>
      _ConfirmarAtividadeViewState<T>();
}

class _ConfirmarAtividadeViewState<T extends EventoAgricola>
    extends State<ConfirmarAtividadeView<T>> {
  DetalhesAtividadeViewModel<T> get _viewModel => widget.viewModel;

  String get _nomeTalhao =>
      widget.talhao?.nomeExibicao ?? 'Talhão #${_viewModel.atividade.idTalhao}';

  late final bool _pedirResponsaveis =
      _viewModel.atividade.responsaveis.isEmpty;

  late final bool _pedirDespesas = _viewModel.despesas.isEmpty;

  late final bool _pedirSecaoExtra =
      widget.construirSecaoExtra != null &&
          (widget.secaoExtraVazia?.call(_viewModel.atividade) ?? false);

  bool get _pedirAlgumaSecao =>
      _pedirResponsaveis || _pedirSecaoExtra || _pedirDespesas;

  Periodo? _janelaDoLancamento() {
    final safra =
        context.read<SafraViewModel>().safraPorId(_viewModel.atividade.idSafra);

    final periodoTalhao = widget.talhao?.periodo;
    final periodoSafra = safra?.periodo;

    if (periodoTalhao == null) return periodoSafra;
    if (periodoSafra == null) return periodoTalhao;

    return periodoTalhao.intersecao(periodoSafra);
  }

  DateTime _tetoDasDatas() => menorData(hoje(), _janelaDoLancamento()?.fim)!;

  late DateTime _dataInicio = apenasData(_viewModel.atividade.dataInicio);

  late final _dataInicioController = TextEditingController(
    text: formatarDataBr(_dataInicio),
  );

  DateTime? _dataFim;
  final _dataFimController = TextEditingController();

  @override
  void dispose() {
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataInicio() async {
    final escolhida = await selecionarData(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: _dataInicio,
      minima: _janelaDoLancamento()?.inicio,
      maxima: _tetoDasDatas(),
    );

    if (escolhida == null) return;

    setState(() {
      _dataInicio = escolhida;
      _dataInicioController.text = formatarDataBr(escolhida);

      if (_dataFim != null && _dataFim!.isBefore(escolhida)) {
        _dataFim = null;
        _dataFimController.clear();
      }
    });
  }

  Future<void> _selecionarDataFim() async {
    final escolhida = await selecionarData(
      context: context,
      ajuda: widget.ajudaDataFim,
      inicial: _dataFim ?? _dataInicio,
      minima: _dataInicio,
      maxima: _tetoDasDatas(),
    );

    if (escolhida == null) return;

    setState(() {
      _dataFim = escolhida;
      _dataFimController.text = formatarDataBr(escolhida);
    });
  }

  Future<void> _confirmar() async {
    if (_dataFim == null) {
      mostrarAviso(context, 'Selecione a data de término.');
      return;
    }

    final sucesso = await _viewModel.confirmar(
      dataInicio: _dataInicio,
      dataFim: _dataFim!,
    );

    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(
        context,
        _viewModel.mensagemErro ?? 'Erro ao confirmar a atividade.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBarPadrao(titulo: widget.titulo),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _construirCartao(),
        ),
      ),
    );
  }

  Widget _construirCartao() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _viewModel.atividade.tituloExibicao,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppCores.verdePrimario,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Talhão: $_nomeTalhao',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(height: 32, color: AppCores.borda),

          _construirCampoData(
            rotulo: 'Data de início',
            controller: _dataInicioController,
            aoTocar: _selecionarDataInicio,
          ),
          _construirCampoData(
            rotulo: 'Data de término',
            controller: _dataFimController,
            dica: 'Selecione a data',
            aoTocar: _selecionarDataFim,
          ),

          ..._construirSecoesPendentes(),

          const SizedBox(height: 8),
          const CaixaAvisoAtencao(
            mensagem: 'Depois de confirmada, a atividade não poderá mais ser '
                'alterada nem excluída — apenas visualizada.',
          ),
          const SizedBox(height: 32),

          CustomButton(
            text: _viewModel.isLoading ? 'Confirmando...' : 'Confirmar',
            onPressed: _viewModel.isLoading ? null : _confirmar,
          ),
        ],
      ),
    );
  }

  List<Widget> _construirSecoesPendentes() {
    if (!_pedirAlgumaSecao) return const [];

    final editavel = !_viewModel.isLoading;

    return [
      const Divider(height: 32, color: AppCores.borda),
      const _AvisoSecoesPendentes(),
      const SizedBox(height: 16),
      if (_pedirResponsaveis) ...[
        SecaoResponsaveisAtividade<T>(
          viewModel: _viewModel,
          podeEditar: editavel,
        ),
        const SizedBox(height: 20),
      ],
      if (_pedirSecaoExtra) ...[
        widget.construirSecaoExtra!(context, _viewModel.atividade),
        const SizedBox(height: 20),
      ],
      if (_pedirDespesas) ...[
        SecaoDespesasAtividade<T>(
          viewModel: _viewModel,
          podeEditar: editavel,
          motivoSomenteLeitura: 'Aguarde a conclusão da operação em andamento '
              'para alterar as despesas.',
        ),
        const SizedBox(height: 20),
      ],
      const Divider(height: 32, color: AppCores.borda),
    ];
  }

  Widget _construirCampoData({
    required String rotulo,
    required TextEditingController controller,
    required VoidCallback aoTocar,
    String? dica,
  }) {
    return GestureDetector(
      onTap: aoTocar,
      child: AbsorbPointer(
        child: CustomTextField(
          label: rotulo,
          controller: controller,
          hintText: dica,
          readOnly: true,
        ),
      ),
    );
  }
}

class _AvisoSecoesPendentes extends StatelessWidget {
  const _AvisoSecoesPendentes();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ainda dá para registrar o que ficou de fora. É opcional, e cada item é '
      'salvo assim que você o seleciona.',
      style: TextStyle(fontSize: 13, color: Colors.black54),
    );
  }
}
