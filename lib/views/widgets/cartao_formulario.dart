import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

class CartaoFormulario extends StatelessWidget {
  final Widget filho;

  const CartaoFormulario({super.key, required this.filho});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(AppEstilos.raioFormulario),
        boxShadow: AppEstilos.sombraElevada,
      ),
      child: filho,
    );
  }
}
