import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UF',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<UF>(
          initialValue: value,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppCores.verdePrimario),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.borda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.borda),
            ),
          ),
          items: UF.values.map((uf) {
            return DropdownMenuItem(
              value: uf,
              child: Text(uf.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
