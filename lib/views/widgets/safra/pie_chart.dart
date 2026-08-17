import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Card com gráfico de pizza (donut) + legenda lateral com quantidade e
/// porcentagem por fatia.
///
/// É um widget genérico do sistema (não depende de Safra nem de nenhum
/// outro módulo específico), então pode ser reaproveitado em qualquer
/// outro relatório/dashboard: basta passar um `Map<String, int>` com o
/// rótulo de cada fatia e seu valor.
///
/// Fica oculto automaticamente (`SizedBox.shrink`) quando não há dados
/// para mostrar.
class PieChartCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Map<String, int> valores;
  final List<Color> paleta;
  final Color corTitulo;

  const PieChartCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.valores,
    required this.paleta,
    this.corTitulo = const Color(0xFF67835C),
  });

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty || valores.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    final total = valores.values.fold<int>(0, (soma, v) => soma + v);
    final entradas = valores.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 18, color: corTitulo),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTitulo),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      valores: entradas.map((e) => e.value).toList(),
                      cores: paleta,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < entradas.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LegendaFatia(
                            cor: paleta[i % paleta.length],
                            rotulo: entradas[i].key,
                            valor: entradas[i].value,
                            porcentagem: total == 0 ? 0 : (entradas[i].value / total * 100),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendaFatia extends StatelessWidget {
  final Color cor;
  final String rotulo;
  final int valor;
  final double porcentagem;

  const _LegendaFatia({
    required this.cor,
    required this.rotulo,
    required this.valor,
    required this.porcentagem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$valor · ${porcentagem.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Desenha um gráfico de pizza (donut) simples a partir de uma lista de
/// valores e cores correspondentes, sem depender de nenhum pacote externo.
class PieChartPainter extends CustomPainter {
  final List<int> valores;
  final List<Color> cores;

  PieChartPainter({required this.valores, required this.cores});

  @override
  void paint(Canvas canvas, Size size) {
    final total = valores.fold<int>(0, (soma, v) => soma + v);
    if (total <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    const espessuraAnel = 26.0;
    final raioExterno = math.min(size.width, size.height) / 2;

    var anguloInicial = -math.pi / 2;
    for (var i = 0; i < valores.length; i++) {
      final valor = valores[i];
      if (valor <= 0) {
        continue;
      }

      final anguloVarredura = (valor / total) * 2 * math.pi;
      final paint = Paint()
        ..color = cores[i % cores.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessuraAnel
        ..strokeCap = StrokeCap.butt;

      final raioTraco = raioExterno - espessuraAnel / 2;
      canvas.drawArc(
        Rect.fromCircle(center: rect.center, radius: raioTraco),
        anguloInicial,
        anguloVarredura,
        false,
        paint,
      );

      anguloInicial += anguloVarredura;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.valores != valores || oldDelegate.cores != cores;
  }
}
