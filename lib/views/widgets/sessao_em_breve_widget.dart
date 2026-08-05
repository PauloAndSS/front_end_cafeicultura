import 'package:flutter/material.dart';

Widget buildSecaoEmBreve(String titulo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Em breve...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}
