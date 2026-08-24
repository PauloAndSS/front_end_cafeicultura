import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class BlocoIdentificacao extends StatelessWidget {
  final bool pessoaFisica;

  final TextEditingController controllerNome;
  final TextEditingController controllerRazaoSocial;
  final TextEditingController controllerCpf;
  final TextEditingController controllerCnpj;
  final TextEditingController controllerInscricaoEstadual;

  final String? dicaNome;
  final String? dicaRazaoSocial;

  const BlocoIdentificacao({
    super.key,
    required this.pessoaFisica,
    required this.controllerNome,
    required this.controllerRazaoSocial,
    required this.controllerCpf,
    required this.controllerCnpj,
    required this.controllerInscricaoEstadual,
    this.dicaNome,
    this.dicaRazaoSocial,
  });

  @override
  Widget build(BuildContext context) {
    if (pessoaFisica) {
      return Column(
        children: [
          CustomTextField(
            label: 'Nome Completo',
            controller: controllerNome,
            validator: Validator.validarNome,
            hintText: dicaNome,
          ),
          CustomTextField(
            label: 'CPF',
            controller: controllerCpf,
            keyboardType: TextInputType.number,
            validator: Validator.validarCPF,
            inputFormatters: [AppMasks.cpf],
            hintText: '000.000.000-00',
          ),
        ],
      );
    }

    return Column(
      children: [
        CustomTextField(
          label: 'Razão Social',
          controller: controllerRazaoSocial,
          validator: Validator.validarRazaoSocial,
          hintText: dicaRazaoSocial,
        ),
        CustomTextField(
          label: 'CNPJ',
          controller: controllerCnpj,
          keyboardType: TextInputType.number,
          validator: Validator.validarCNPJ,
          inputFormatters: [AppMasks.cnpj],
          hintText: '00.000.000/0000-00',
        ),
        CustomTextField(
          label: 'Inscrição Estadual (Opcional)',
          controller: controllerInscricaoEstadual,
          keyboardType: TextInputType.number,
          validator: Validator.validarInscEstadual,
          hintText: 'Digite sua inscrição estadual (Opcional)',
        ),
      ],
    );
  }
}
