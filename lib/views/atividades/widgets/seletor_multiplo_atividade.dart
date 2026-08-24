import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class SeletorMultiploAtividade<T> extends StatelessWidget {
  final IconData icone;

  final String rotuloVazio;

  final List<T> selecionados;
  final String Function(T item) rotuloItem;
  final VoidCallback aoAbrir;
  final ValueChanged<T> aoRemover;

  const SeletorMultiploAtividade({
    super.key,
    required this.icone,
    required this.rotuloVazio,
    required this.selecionados,
    required this.rotuloItem,
    required this.aoAbrir,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final quantidade = selecionados.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: aoAbrir,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppCores.borda),
            ),
            child: Row(
              children: [
                Icon(icone, color: AppCores.verdePrimario),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quantidade == 0
                        ? rotuloVazio
                        : '$quantidade selecionado(s)',
                    style: TextStyle(
                      fontSize: 14,
                      color: quantidade == 0 ? Colors.black26 : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
        if (quantidade > 0) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: selecionados.map((item) {
              return Chip(
                label: Text(
                  rotuloItem(item),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                backgroundColor: AppCores.verdeSecundario,
                deleteIconColor: Colors.white,
                onDeleted: () => aoRemover(item),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
