import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool opcional;
  final bool habilitado;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
    this.opcional = false,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, label, opcional: opcional),
        TextFormField(
          controller: controller,
          enabled: habilitado,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            filled: readOnly || !habilitado,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
