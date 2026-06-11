import 'package:flutter/material.dart';

class LogoCircular extends StatelessWidget {
  final double size;

  const LogoCircular({
    super.key,
    this.size = 130.0, // Tamanho base
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/images/logo_cafe.png'),
          fit: BoxFit.contain,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}