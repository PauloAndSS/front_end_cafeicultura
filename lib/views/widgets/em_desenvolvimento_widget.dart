import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class EmDesenvolvimentoWidget extends StatelessWidget {
  final String titulo;

  const EmDesenvolvimentoWidget({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: AppCores.verdeSecundario),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppCores.verdePrimario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Em desenvolvimento...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
