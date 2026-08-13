import 'package:flutter/material.dart';

const _verdePrimario = Color(0xFF67835C);
const _verdeSecundario = Color(0xFF8FA67E);
const _cinzaBorda = Color(0xFFE0E0E0);

/// Campo que abre um modal de seleção e mostra o escolhido como chips.
///
/// Responsáveis e insumos usavam duas cópias do mesmo widget, divergindo só no
/// ícone, no texto e em como o item vira rótulo. Aqui isso entra por parâmetro.
///
/// [aoRemover] recebe o item, não o índice: o chamador filtra pela chave que
/// fizer sentido para o tipo dele (`id` de responsável, `idInsumo` de insumo),
/// porque nenhum dos dois implementa `==`.
class SeletorMultiploAtividade<T> extends StatelessWidget {
  final IconData icone;

  /// Texto quando nada foi escolhido — 'Selecionar responsáveis'.
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
              border: Border.all(color: _cinzaBorda),
            ),
            child: Row(
              children: [
                Icon(icone, color: _verdePrimario),
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
                backgroundColor: _verdeSecundario,
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
