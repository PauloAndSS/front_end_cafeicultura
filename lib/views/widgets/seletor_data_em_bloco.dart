import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class SeletorDataEmBloco extends StatelessWidget {
  final DateTime data;
  final VoidCallback aoTocar;

  const SeletorDataEmBloco({
    super.key,
    required this.data,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: aoTocar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppCores.verdePrimario,
            ),
            const SizedBox(width: 10),
            Text(formatarDataBr(data)),
          ],
        ),
      ),
    );
  }
}
