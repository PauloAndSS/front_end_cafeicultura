import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_transacao_financeira.dart';

Future<Despesa?> mostrarCadastroTransacao({
  required BuildContext context,
  required int idPropriedade,
  required CarregarPessoasMixin catalogoDePessoas,
  List<Pessoa> responsaveis = const [],
}) {
  return showDialog<Despesa>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TransacaoFinanceiraDialog(
      idPropriedade: idPropriedade,
      catalogoDePessoas: catalogoDePessoas,
      responsaveis: responsaveis,
    ),
  );
}

class _TransacaoFinanceiraDialog extends StatefulWidget {
  final int idPropriedade;
  final CarregarPessoasMixin catalogoDePessoas;
  final List<Pessoa> responsaveis;

  const _TransacaoFinanceiraDialog({
    required this.idPropriedade,
    required this.catalogoDePessoas,
    required this.responsaveis,
  });

  @override
  State<_TransacaoFinanceiraDialog> createState() =>
      _TransacaoFinanceiraDialogState();
}

class _TransacaoFinanceiraDialogState
    extends State<_TransacaoFinanceiraDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();

  TipoOperacao? _tipoOperacao = TransacaoFinanceira.operacaoUnica;
  FormaPagamento? _formaPagamento;
  Pessoa? _beneficiado;

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Nova Despesa',
        style: TextStyle(
          color: AppCores.verdePrimario,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: BlocoTransacaoFinanceira(
            tipoOperacao: _tipoOperacao,
            formaPagamento: _formaPagamento,
            beneficiado: _beneficiado,
            controllerValor: _valorController,
            controllerDescricao: _descricaoController,
            responsaveisSugeridos: widget.responsaveis,
            catalogoDePessoas: widget.catalogoDePessoas,
            categoriasBeneficiado: TipoPapel.values,
            aoSelecionarTipoOperacao: (valor) =>
                setState(() => _tipoOperacao = valor),
            aoSelecionarFormaPagamento: (valor) =>
                setState(() => _formaPagamento = valor),
            aoSelecionarBeneficiado: (valor) =>
                setState(() => _beneficiado = valor),
          ),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: 'Adicionar',
        aoConfirmar: _confirmar,
      ),
    );
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final despesa = Despesa(
      idPropriedade: widget.idPropriedade,
      valor: AppMasks.paraDouble(_valorController.text)!,
      formaPagamento: _formaPagamento!,
      tipoOperacao: _tipoOperacao!,
      beneficiado: _beneficiado,
      descricao: _descricaoController.text,
    );

    Navigator.of(context).pop(despesa);
  }
}
