import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class LogoCircular extends StatelessWidget {
  final double size;

  const LogoCircular({
    super.key,
    this.size = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppCores.superficie,
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/images/logo_cafe.png'),
          fit: BoxFit.contain,
        ),
        boxShadow: [
          BoxShadow(
            color: AppCores.textoPrimario.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
