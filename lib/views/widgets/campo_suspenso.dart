import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';

class CampoSuspenso<T> extends StatelessWidget {
  final String rotulo;
  final T? valor;
  final List<T> itens;
  final String Function(T item) rotuloItem;
  final Widget Function(T item)? seloItem;
  final String? dica;
  final ValueChanged<T?>? aoSelecionar;
  final FormFieldValidator<T>? validador;
  final Key? chaveDoSeletor;

  const CampoSuspenso({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.itens,
    required this.rotuloItem,
    required this.aoSelecionar,
    this.seloItem,
    this.dica,
    this.validador,
    this.chaveDoSeletor,
  });

  @override
  Widget build(BuildContext context) {
    final textoDaDica = dica;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, rotulo),
        DropdownButtonFormField<T>(
          key: chaveDoSeletor,
          initialValue: valor,
          isExpanded: true,
          style: estiloDeValorDeCampo(context),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppCores.acao),
          hint: textoDaDica == null ? null : dicaDeSeletor(context, textoDaDica),
          items: [
            for (final item in itens)
              DropdownMenuItem<T>(value: item, child: _construirItem(item)),
          ],
          onChanged: aoSelecionar,
          validator: validador,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _construirItem(T item) {
    final selo = seloItem;

    final texto = Text(rotuloItem(item), overflow: TextOverflow.ellipsis);

    if (selo == null) return texto;

    return Row(
      children: [
        Flexible(child: texto),
        selo(item),
      ],
    );
  }
}
