import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CartaoGrafico extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color corTitulo;
  final bool mostrarTitulo;

  final WidgetBuilder construirGrafico;

  final Map<String, int> valores;

  const CartaoGrafico({
    super.key,
    required this.titulo,
    required this.icone,
    required this.valores,
    required this.construirGrafico,
    this.corTitulo = AppCores.verdePrimario,
    this.mostrarTitulo = true,
  });

  static bool semDados(Map<String, int> valores) =>
      valores.isEmpty || valores.values.every((v) => v == 0);

  @override
  Widget build(BuildContext context) {
    if (semDados(valores)) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mostrarTitulo) ...[
              Row(
                children: [
                  Icon(icone, size: 18, color: corTitulo),
                  const SizedBox(width: 6),
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corTitulo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            construirGrafico(context),
          ],
        ),
      ),
    );
  }
}

class CartaoIndicador extends StatelessWidget {
  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;

  const CartaoIndicador({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rotulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}