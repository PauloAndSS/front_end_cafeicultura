import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/widgets/campo_quantidade_comprada.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_transacao_financeira.dart';

Future<Insumo?> mostrarRegistroDeCompra({
  required BuildContext context,
  required InsumosViewModel viewModel,
  required Insumo insumo,
  required int idPropriedade,
  List<Pessoa> fornecedores = const [],
}) {
  return showDialog<Insumo>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RegistrarCompraDialog(
      viewModel: viewModel,
      insumo: insumo,
      idPropriedade: idPropriedade,
      fornecedores: fornecedores,
    ),
  );
}

class _RegistrarCompraDialog extends StatefulWidget {
  final InsumosViewModel viewModel;
  final Insumo insumo;
  final int idPropriedade;
  final List<Pessoa> fornecedores;

  const _RegistrarCompraDialog({
    required this.viewModel,
    required this.insumo,
    required this.idPropriedade,
    required this.fornecedores,
  });

  @override
  State<_RegistrarCompraDialog> createState() => _RegistrarCompraDialogState();
}

class _RegistrarCompraDialogState extends State<_RegistrarCompraDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtdCompradaController = TextEditingController();
  final _valorController = TextEditingController();

  TipoOperacao? _tipoOperacao = TransacaoFinanceira.operacaoUnica;
  FormaPagamento? _formaPagamento;
  Pessoa? _beneficiado;

  String? _erro;
  bool _salvando = false;

  bool get _semFornecedores => widget.fornecedores.isEmpty;

  @override
  void dispose() {
    _qtdCompradaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _erro = 'Revise os campos destacados.');
      return;
    }

    setState(() {
      _erro = null;
      _salvando = true;
    });

    final atualizado = await widget.viewModel.registrarCompra(
      insumo: widget.insumo,
      despesa: _montarDespesa(),
      qtdComprada: AppMasks.paraDouble(_qtdCompradaController.text)!,
    );

    if (!mounted) return;

    if (atualizado == null) {
      setState(() {
        _salvando = false;
        _erro = widget.viewModel.mensagemErroCompra ??
            'Erro ao registrar a compra do insumo.';
      });
      return;
    }

    Navigator.of(context).pop(atualizado);
  }

  Despesa _montarDespesa() {
    return Despesa(
      idPropriedade: widget.idPropriedade,
      valor: AppMasks.paraDouble(_valorController.text)!,
      formaPagamento: _formaPagamento!,
      tipoOperacao: _tipoOperacao!,
      beneficiado: _beneficiado,
      descricao: widget.insumo.descricao,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Registrar Compra',
        style: TextStyle(
          color: AppCores.verdePrimario,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_semFornecedores) ...[
                const CaixaAvisoAtencao(
                  mensagem:
                      'Cadastre um fornecedor antes de registrar a compra deste insumo.',
                ),
                const SizedBox(height: 16),
              ],
              if (_erro != null) ...[
                CaixaAviso(
                  icone: Icons.error_outline,
                  cor: AppCores.erro,
                  corDoTexto: AppCores.erro,
                  mensagem: _erro!,
                ),
                const SizedBox(height: 16),
              ],
              LinhaInfo(rotulo: 'Insumo', valor: widget.insumo.descricao),
              LinhaInfo(
                rotulo: 'Unidade de medida',
                valor: widget.insumo.unidadeFormatada,
              ),
              LinhaInfo(
                rotulo: 'Saldo atual',
                valor: widget.insumo.saldoFormatado,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              CampoQuantidadeComprada(
                controller: _qtdCompradaController,
                medida: widget.insumo.medida,
                habilitado: !_salvando,
              ),
              const SizedBox(height: 16),
              BlocoTransacaoFinanceira(
                tipoOperacao: _tipoOperacao,
                formaPagamento: _formaPagamento,
                beneficiado: _beneficiado,
                controllerValor: _valorController,
                demaisPessoas: widget.fornecedores,
                habilitado: !_salvando,
                rotuloBeneficiado: 'Fornecedor',
                aoSelecionarTipoOperacao: (valor) =>
                    setState(() => _tipoOperacao = valor),
                aoSelecionarFormaPagamento: (valor) =>
                    setState(() => _formaPagamento = valor),
                aoSelecionarBeneficiado: (valor) =>
                    setState(() => _beneficiado = valor),
              ),
            ],
          ),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: _salvando ? 'Salvando...' : 'Registrar',
        aoConfirmar: _salvando ? null : _salvar,
      ),
    );
  }
}
