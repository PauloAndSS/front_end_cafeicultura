import 'package:flutter/material.dart';

/// Card com gráfico de barras verticais e o valor impresso acima de cada
/// barra.
///
/// É o par do `PieChartCard` para série ordenada: a pizza compara partes de um
/// todo, este compara a mesma grandeza ao longo de uma sequência (meses, por
/// exemplo), onde a ordem das fatias significa alguma coisa.
///
/// Genérico como ele — recebe um `Map<String, int>` de rótulo para valor e não
/// sabe nada sobre o domínio — e some sozinho (`SizedBox.shrink`) quando não há
/// o que mostrar.
///
/// Não desenha eixo Y: o número em cima de cada barra já diz a altura, e uma
/// escala lateral custaria largura que um telefone de 360dp não tem para dar.
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
    this.cor = const Color(0xFF67835C),
    this.corTitulo = const Color(0xFF67835C),
  });

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty || valores.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

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
            SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: BarChartPainter(valores: valores, cor: cor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desenha as barras, o rótulo de cada uma e o valor no topo, sem depender de
/// nenhum pacote externo — como o `PieChartPainter`.
class BarChartPainter extends CustomPainter {
  final Map<String, int> valores;
  final Color cor;

  BarChartPainter({required this.valores, required this.cor});

  /// Largura máxima de uma barra. Sem teto, um gráfico de um mês só viraria um
  /// bloco ocupando a largura inteira do card.
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

    // A área das barras é o que sobra depois de reservar as duas faixas de
    // texto: o valor em cima e o rótulo embaixo.
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

      // Meses sem evento entram como barra zero: sem eles a sequência mentiria
      // sobre a distribuição no tempo. Só o traço da base é desenhado, para o
      // rótulo não ficar solto.
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

  /// Escreve [texto] centralizado em [centroX], truncando no espaço da fatia.
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
