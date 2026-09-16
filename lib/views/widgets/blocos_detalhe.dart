import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';

const estiloRotuloDetalhe = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppCores.textoSecundario,
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
              style: const TextStyle(color: AppCores.textoPrimario, fontSize: 15),
              textAlign: TextAlign.end,
            ),
          ),
          if (onEditar != null) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppCores.acao,
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
  final bool opcional;

  const SecaoEditavel({
    super.key,
    required this.titulo,
    required this.conteudo,
    this.onEditar,
    this.opcional = false,
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
              Flexible(child: Text(titulo, style: estiloRotuloDetalhe)),
              if (opcional) const MarcaOpcional(),
              if (onEditar != null) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppCores.acao,
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

class ChipsLista<T> extends StatelessWidget {
  final List<T> itens;
  final String Function(T item) rotuloItem;
  final String textoVazio;
  final ValueChanged<T>? aoTocar;
  final ValueChanged<T>? aoRemover;
  final bool Function(T item)? podeRemover;

  const ChipsLista({
    super.key,
    required this.itens,
    required this.rotuloItem,
    required this.textoVazio,
    this.aoTocar,
    this.aoRemover,
    this.podeRemover,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return Text(
        textoVazio,
        style: const TextStyle(color: AppCores.textoPrimario, fontSize: 15),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: itens.map(_construirChip).toList(),
    );
  }

  Widget _construirChip(T item) {
    final rotulo = Text(
      rotuloItem(item),
      style: const TextStyle(color: AppCores.sobreAcao, fontSize: 13),
    );

    final remover = aoRemover;
    final removivel = remover != null && (podeRemover?.call(item) ?? true);
    final aoTocarItem = aoTocar;

    if (aoTocarItem == null) {
      return Chip(
        label: rotulo,
        backgroundColor: AppCores.acao,
        deleteIconColor: AppCores.sobreAcao,
        onDeleted: removivel ? () => remover(item) : null,
      );
    }

    return InputChip(
      label: rotulo,
      backgroundColor: AppCores.acao,
      deleteIconColor: AppCores.sobreAcao,
      onPressed: () => aoTocarItem(item),
      onDeleted: removivel ? () => remover(item) : null,
    );
  }
}
