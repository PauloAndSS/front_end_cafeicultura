import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CampoQuantidadeComprada extends StatelessWidget {
  final TextEditingController controller;
  final MedidaInsumo? medida;
  final bool habilitado;

  const CampoQuantidadeComprada({
    super.key,
    required this.controller,
    required this.medida,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, 'Quantidade comprada'),
        TextFormField(
          controller: controller,
          enabled: habilitado,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppMasks.decimal],
          decoration: InputDecoration(
            hintText: '0,00',
            hintStyle: const TextStyle(color: AppCores.textoTerciario, fontSize: 14),
            suffixText: medida?.sigla,
          ),
          validator: Validator.valorPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
