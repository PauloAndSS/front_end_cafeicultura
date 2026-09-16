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

  final UF? uf;
  final ValueChanged<UF?> aoSelecionarUf;

  final String dicaLogradouro;
  final String dicaBairro;

  final bool Function()? exigirPreenchimento;

  const BlocoEndereco({
    super.key,
    required this.controllerCep,
    required this.controllerLogradouro,
    required this.controllerBairro,
    required this.controllerCidade,
    required this.uf,
    required this.aoSelecionarUf,
    this.exigirPreenchimento,
    this.dicaLogradouro = 'Rua, Avenida, número, complemento...',
    this.dicaBairro = 'Digite o bairro ou distrito',
  });

  bool get _exigido => exigirPreenchimento?.call() ?? true;

  String? _seExigido(String? Function(String?) validar, String? valor) {
    return _exigido ? validar(valor) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'CEP',
          controller: controllerCep,
          keyboardType: TextInputType.number,
          validator: (valor) => _seExigido(Validator.validarCEP, valor),
          inputFormatters: [AppMasks.cep],
          hintText: 'Digite o CEP (apenas números)',
        ),
        CustomTextField(
          label: 'Logradouro',
          controller: controllerLogradouro,
          validator: (valor) => _seExigido(Validator.validarNome, valor),
          hintText: dicaLogradouro,
        ),
        CustomTextField(
          label: 'Bairro/Distrito',
          controller: controllerBairro,
          validator: (valor) => _seExigido(Validator.validarNome, valor),
          hintText: dicaBairro,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _campoCidade()),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: _campoUf()),
          ],
        ),
      ],
    );
  }

  Widget _campoCidade() => CustomTextField(
    label: 'Cidade',
    controller: controllerCidade,
    validator: (valor) => _seExigido(Validator.validarNome, valor),
    hintText: 'Nome da cidade',
  );

  Widget _campoUf() => UfDropdown(
    value: uf,
    onChanged: aoSelecionarUf,
    validator: (valor) {
      if (!_exigido) return null;
      return valor == null ? 'Obrigatório' : null;
    },
  );
}
