import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

Future<double?> mostrarQuantidadeInsumo({
  required BuildContext context,
  required Insumo insumo,
  double? quantidadeAtual,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _QuantidadeInsumoDialog(
      insumo: insumo,
      quantidadeAtual: quantidadeAtual,
    ),
  );
}

class _QuantidadeInsumoDialog extends StatefulWidget {
  final Insumo insumo;
  final double? quantidadeAtual;

  const _QuantidadeInsumoDialog({
    required this.insumo,
    required this.quantidadeAtual,
  });

  @override
  State<_QuantidadeInsumoDialog> createState() =>
      _QuantidadeInsumoDialogState();
}

class _QuantidadeInsumoDialogState extends State<_QuantidadeInsumoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: _quantidadeInicial());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _quantidadeInicial() {
    final atual = widget.quantidadeAtual;
    if (atual == null) return '';

    return formatarDecimal(atual);
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(AppMasks.paraDouble(_controller.text));
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.insumo.descricao,
        style: const TextStyle(
          color: AppCores.verdePrimario,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppMasks.decimal],
          decoration: InputDecoration(
            labelText: 'Quantidade utilizada',
            hintText: '0,00',
            suffixText: widget.insumo.medida.sigla,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.borda),
            ),
          ),
          validator: Validator.valorPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: (_) => _confirmar(),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: 'Confirmar',
        aoConfirmar: _confirmar,
      ),
    );
  }
}
