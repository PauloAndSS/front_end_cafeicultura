import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:intl/intl.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);

/// Pergunta quanto do [insumo] foi utilizado.
///
/// É um `StatefulWidget` — e não um `showDialog` com controller local — porque
/// o future de `showDialog` completa no instante do `pop`, **antes** da
/// animação de saída (ver `Route.didComplete`). Descartar o controller ali
/// deixaria o `TextFormField` ainda montado apontando para um `ChangeNotifier`
/// morto, e a exceção resultante interrompe a desmontagem da subárvore.
///
/// Devolve `null` se o usuário cancelar.
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

  /// O texto tem que sair no mesmo formato que [AppMasks.decimal] produz —
  /// milhar com ponto, decimal com vírgula e no máximo duas casas —, senão
  /// editar um valor já salvo começa com a máscara brigando com o próprio
  /// conteúdo: acima de duas casas ela recusa toda digitação seguinte.
  String _quantidadeInicial() {
    final atual = widget.quantidadeAtual;
    if (atual == null) return '';

    return NumberFormat('#,##0.##', 'pt_BR').format(atual);
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(AppMasks.paraDouble(_controller.text));
  }

  String? _validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obrigatório';

    final quantidade = AppMasks.paraDouble(valor);

    if (quantidade == null) return 'Valor inválido';
    if (quantidade <= 0) return 'Informe um valor maior que zero';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.insumo.descricao,
        style: const TextStyle(
          color: _verdePrimario,
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
              borderSide: const BorderSide(color: _cinzaBorda),
            ),
          ),
          validator: _validar,
          onFieldSubmitted: (_) => _confirmar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _confirmar,
          child: const Text(
            'Confirmar',
            style: TextStyle(color: _verdePrimario, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
