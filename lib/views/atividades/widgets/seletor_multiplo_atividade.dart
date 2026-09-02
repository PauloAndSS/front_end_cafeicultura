import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';

class SeletorMultiploAtividade<T> extends StatelessWidget {
  final IconData icone;

  final String rotuloVazio;

  final List<T> selecionados;
  final String Function(T item) rotuloItem;
  final VoidCallback aoAbrir;
  final ValueChanged<T>? aoRemover;
  final String? rotuloContagem;
  final bool Function(T item)? podeRemover;
  final ValueChanged<T>? aoTocarItem;

  const SeletorMultiploAtividade({
    super.key,
    required this.icone,
    required this.rotuloVazio,
    required this.selecionados,
    required this.rotuloItem,
    required this.aoAbrir,
    this.aoRemover,
    this.rotuloContagem,
    this.podeRemover,
    this.aoTocarItem,
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
                        : rotuloContagem ?? '$quantidade selecionado(s)',
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
          ChipsLista<T>(
            itens: selecionados,
            rotuloItem: rotuloItem,
            textoVazio: '',
            aoTocar: aoTocarItem,
            aoRemover: aoRemover,
            podeRemover: podeRemover,
          ),
        ],
      ],
    );
  }
}
