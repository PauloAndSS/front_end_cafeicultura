import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CartaoDetalhe extends StatelessWidget {
  final String titulo;

  final Widget? selo;

  final List<Widget> conteudo;

  final bool transparente;

  final Color? corDivisor;

  const CartaoDetalhe({
    super.key,
    required this.titulo,
    required this.conteudo,
    this.selo,
    this.transparente = false,
    this.corDivisor,
  });

  @override
  Widget build(BuildContext context) {
    final corpo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
            ?selo,
          ],
        ),
        Divider(height: 24, color: corDivisor),
        ...conteudo,
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: transparente
          ? Material(type: MaterialType.transparency, child: corpo)
          : corpo,
    );
  }
}
