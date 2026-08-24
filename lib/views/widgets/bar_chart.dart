import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_grafico.dart';

class BarChartCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Map<String, int> valores;
  final Color cor;
  final Color corTitulo;

  const BarChartCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.valores,
    this.cor = AppCores.verdePrimario,
    this.corTitulo = AppCores.verdePrimario,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoGrafico(
      titulo: titulo,
      icone: icone,
      corTitulo: corTitulo,
      valores: valores,
      construirGrafico: (context) => SizedBox(
        height: 160,
        width: double.infinity,
        child: CustomPaint(
          painter: BarChartPainter(valores: valores, cor: cor),
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<String, int> valores;
  final Color cor;

  BarChartPainter({required this.valores, required this.cor});

  static const double _larguraMaximaBarra = 48;

  static const double _alturaRotulo = 18;
  static const double _alturaValor = 16;
  static const double _espacoEntreBarras = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final entradas = valores.entries.toList();
    if (entradas.isEmpty) {
      return;
    }

    final maiorValor = entradas.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maiorValor <= 0) {
      return;
    }

    final alturaDisponivel = size.height - _alturaRotulo - _alturaValor;
    if (alturaDisponivel <= 0) {
      return;
    }

    final larguraFatia = size.width / entradas.length;
    final larguraBarra =
        (larguraFatia - _espacoEntreBarras).clamp(1.0, _larguraMaximaBarra);

    final pintura = Paint()..color = cor;

    for (var i = 0; i < entradas.length; i++) {
      final entrada = entradas[i];
      final centroX = larguraFatia * i + larguraFatia / 2;

      final alturaBarra = (entrada.value / maiorValor) * alturaDisponivel;
      final topoBarra = _alturaValor + (alturaDisponivel - alturaBarra);

      final retangulo = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          centroX - larguraBarra / 2,
          entrada.value == 0 ? topoBarra - 2 : topoBarra,
          larguraBarra,
          entrada.value == 0 ? 2 : alturaBarra,
        ),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      canvas.drawRRect(
        retangulo,
        entrada.value == 0 ? (Paint()..color = cor.withValues(alpha: 0.25)) : pintura,
      );

      if (entrada.value > 0) {
        _desenharTexto(
          canvas,
          '${entrada.value}',
          centroX,
          topoBarra - _alturaValor,
          larguraFatia,
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
        );
      }

      _desenharTexto(
        canvas,
        entrada.key,
        centroX,
        size.height - _alturaRotulo + 4,
        larguraFatia,
        TextStyle(fontSize: 11, color: Colors.grey.shade600),
      );
    }
  }

  void _desenharTexto(
    Canvas canvas,
    String texto,
    double centroX,
    double topo,
    double larguraDisponivel,
    TextStyle estilo,
  ) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: larguraDisponivel);

    pintor.paint(canvas, Offset(centroX - pintor.width / 2, topo));
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.valores != valores || oldDelegate.cor != cor;
  }
}
