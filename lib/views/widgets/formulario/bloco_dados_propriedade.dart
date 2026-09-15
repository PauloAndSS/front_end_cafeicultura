import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class BlocoDadosPropriedade extends StatelessWidget {
  final TextEditingController controllerNome;
  final TextEditingController controllerTamanho;

  final Medida medida;
  final ValueChanged<Medida> aoSelecionarMedida;

  const BlocoDadosPropriedade({
    super.key,
    required this.controllerNome,
    required this.controllerTamanho,
    required this.medida,
    required this.aoSelecionarMedida,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Nome da Propriedade',
          controller: controllerNome,
          validator: Validator.validarNome,
          hintText: 'Ex: Sítio Vô Augusto',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Tamanho',
                controller: controllerTamanho,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [AppMasks.decimal],
                hintText: 'Ex: 15,5',
                validator: Validator.obrigatorio,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CampoSuspenso<Medida>(
                rotulo: 'Medida',
                valor: medida,
                itens: Medida.values,
                rotuloItem: (medida) => medida.nomeExibicao,
                aoSelecionar: (selecionada) {
                  if (selecionada != null) aoSelecionarMedida(selecionada);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
