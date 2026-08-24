import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

const estiloRotuloDetalhe = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.black54,
  fontSize: 15,
);

class LinhaInfo extends StatelessWidget {
  final String rotulo;
  final String valor;
  final VoidCallback? onEditar;
  final EdgeInsetsGeometry padding;

  const LinhaInfo({
    super.key,
    required this.rotulo,
    required this.valor,
    this.onEditar,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final linha = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: estiloRotuloDetalhe),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              textAlign: TextAlign.end,
            ),
          ),
          if (onEditar != null) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppCores.verdePrimario,
            ),
          ],
        ],
      ),
    );

    if (onEditar == null) return linha;

    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(8),
      child: linha,
    );
  }
}

class SecaoEditavel extends StatelessWidget {
  final String titulo;
  final Widget conteudo;
  final VoidCallback? onEditar;

  const SecaoEditavel({
    super.key,
    required this.titulo,
    required this.conteudo,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final bloco = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(titulo, style: estiloRotuloDetalhe),
              if (onEditar != null) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppCores.verdePrimario,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: conteudo),
        ],
      ),
    );

    if (onEditar == null) return bloco;

    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(8),
      child: bloco,
    );
  }
}

class ChipsLista extends StatelessWidget {
  final List<String> rotulos;
  final String textoVazio;

  const ChipsLista({
    super.key,
    required this.rotulos,
    required this.textoVazio,
  });

  @override
  Widget build(BuildContext context) {
    if (rotulos.isEmpty) {
      return Text(
        textoVazio,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: rotulos.map((rotulo) {
        return Chip(
          label: Text(
            rotulo,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: AppCores.verdeSecundario,
        );
      }).toList(),
    );
  }
}
