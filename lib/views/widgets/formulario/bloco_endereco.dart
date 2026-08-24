import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';

class BlocoEndereco extends StatelessWidget {
  final TextEditingController controllerCep;
  final TextEditingController controllerLogradouro;
  final TextEditingController controllerBairro;
  final TextEditingController controllerCidade;
  final TextEditingController? controllerPais;

  final UF? uf;
  final ValueChanged<UF?> aoSelecionarUf;

  final String dicaLogradouro;
  final String dicaBairro;

  const BlocoEndereco({
    super.key,
    required this.controllerCep,
    required this.controllerLogradouro,
    required this.controllerBairro,
    required this.controllerCidade,
    required this.uf,
    required this.aoSelecionarUf,
    this.controllerPais,
    this.dicaLogradouro = 'Rua, Avenida, número, complemento...',
    this.dicaBairro = 'Digite o bairro ou distrito',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'CEP',
          controller: controllerCep,
          keyboardType: TextInputType.number,
          validator: Validator.validarCEP,
          inputFormatters: [AppMasks.cep],
          hintText: 'Digite o CEP (apenas números)',
        ),
        CustomTextField(
          label: 'Logradouro',
          controller: controllerLogradouro,
          validator: Validator.validarNome,
          hintText: dicaLogradouro,
        ),
        CustomTextField(
          label: 'Bairro',
          controller: controllerBairro,
          validator: Validator.validarNome,
          hintText: dicaBairro,
        ),
        if (controllerPais == null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _campoCidade()),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _campoUf()),
            ],
          )
        else ...[
          _campoCidade(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _campoUf()),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'País',
                  controller: controllerPais!,
                  validator: Validator.obrigatorio,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _campoCidade() => CustomTextField(
    label: 'Cidade',
    controller: controllerCidade,
    validator: Validator.validarNome,
    hintText: 'Nome da cidade',
  );

  Widget _campoUf() => UfDropdown(
    value: uf,
    onChanged: aoSelecionarUf,
    validator: (valor) => valor == null ? 'Obrigatório' : null,
  );
}
