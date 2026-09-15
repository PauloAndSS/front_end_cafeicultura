import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

Widget buildSecaoEmBreve(String titulo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppCores.textoPrimario,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: AppEstilos.cartao(),
        child: const Center(
          child: Text(
            'Em breve...',
            style: TextStyle(
              fontSize: 14,
              color: AppCores.textoSecundario,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}
