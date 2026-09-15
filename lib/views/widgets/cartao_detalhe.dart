import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

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
                color: AppCores.acao,
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
      decoration: AppEstilos.cartao(),
      child: transparente
          ? Material(type: MaterialType.transparency, child: corpo)
          : corpo,
    );
  }
}
