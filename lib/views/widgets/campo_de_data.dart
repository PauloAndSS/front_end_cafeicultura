import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class CampoDeData extends StatelessWidget {
  final String label;

  final TextEditingController controller;

  final VoidCallback aoTocar;

  final String hintText;

  final bool obrigatorio;

  const CampoDeData({
    super.key,
    required this.label,
    required this.controller,
    required this.aoTocar,
    this.hintText = 'Selecione a data',
    this.obrigatorio = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          controller: controller,
          hintText: hintText,
          readOnly: true,
          validator: obrigatorio ? Validator.obrigatorio : null,
        ),
      ),
    );
  }
}
