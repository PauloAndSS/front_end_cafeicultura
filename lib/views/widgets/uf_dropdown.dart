import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';

class UfDropdown extends StatelessWidget {
  final UF? value;
  final ValueChanged<UF?> onChanged;
  final String? Function(UF?)? validator;

  const UfDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CampoSuspenso<UF>(
      rotulo: 'UF',
      valor: value,
      itens: UF.values,
      rotuloItem: (uf) => uf.name,
      aoSelecionar: onChanged,
      validador: validator,
    );
  }
}
