import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';

class SecaoListaAtividade<T> extends StatelessWidget {
  final String titulo;
  final IconData icone;

  final String rotuloVazio;
  final String textoVazio;
  final String rotuloContagem;

  final List<T> itens;
  final String Function(T item) rotuloItem;

  final VoidCallback? aoAbrir;
  final ValueChanged<T>? aoRemover;
  final bool Function(T item)? podeRemover;
  final ValueChanged<T>? aoTocarItem;

  const SecaoListaAtividade({
    super.key,
    required this.titulo,
    required this.icone,
    required this.rotuloVazio,
    required this.textoVazio,
    required this.rotuloContagem,
    required this.itens,
    required this.rotuloItem,
    this.aoAbrir,
    this.aoRemover,
    this.podeRemover,
    this.aoTocarItem,
  });

  @override
  Widget build(BuildContext context) {
    final abrir = aoAbrir;

    if (abrir == null) {
      return SecaoEditavel(
        titulo: titulo,
        conteudo: ChipsLista<T>(
          itens: itens,
          rotuloItem: rotuloItem,
          textoVazio: textoVazio,
          aoTocar: aoTocarItem,
        ),
      );
    }

    return SecaoEditavel(
      titulo: titulo,
      conteudo: SeletorMultiploAtividade<T>(
        icone: icone,
        rotuloVazio: rotuloVazio,
        selecionados: itens,
        rotuloItem: rotuloItem,
        rotuloContagem: rotuloContagem,
        aoAbrir: abrir,
        aoRemover: aoRemover,
        podeRemover: podeRemover,
        aoTocarItem: aoTocarItem,
      ),
    );
  }
}
