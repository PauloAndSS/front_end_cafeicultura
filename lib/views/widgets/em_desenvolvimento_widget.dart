import 'package:flutter/material.dart';

class EmDesenvolvimentoWidget extends StatelessWidget {
  final String titulo;

  const EmDesenvolvimentoWidget({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: Color(0xFF8FA67E)),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF67835C),
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
