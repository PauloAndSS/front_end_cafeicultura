import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class BlocoContato extends StatelessWidget {
  final TextEditingController controllerEmail;
  final TextEditingController controllerTelefone;

  final String? dicaEmail;
  final String? dicaTelefone;

  const BlocoContato({
    super.key,
    required this.controllerEmail,
    required this.controllerTelefone,
    this.dicaEmail,
    this.dicaTelefone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'E-mail',
          controller: controllerEmail,
          keyboardType: TextInputType.emailAddress,
          validator: Validator.validarEmail,
          hintText: dicaEmail,
        ),
        CustomTextField(
          label: 'Telefone',
          controller: controllerTelefone,
          keyboardType: TextInputType.phone,
          validator: Validator.validarTelefone,
          inputFormatters: [AppMasks.telefone],
          hintText: dicaTelefone,
        ),
      ],
    );
  }
}
