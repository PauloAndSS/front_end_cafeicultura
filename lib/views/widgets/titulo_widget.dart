import 'package:flutter/material.dart';

class TituloWidget extends StatelessWidget {
  final String titulo;

  const TituloWidget({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 200,
          height: 1,
          color: Colors.black54,
        ),
      ],
    );
  }
}
