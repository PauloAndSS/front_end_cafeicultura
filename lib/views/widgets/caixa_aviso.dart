import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CaixaAviso extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final Color corDoTexto;
  final String mensagem;
  final List<String> itens;
  final Widget? acao;

  const CaixaAviso({
    super.key,
    required this.icone,
    required this.cor,
    required this.corDoTexto,
    required this.mensagem,
    this.itens = const [],
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensagem,
                  style: TextStyle(
                    color: corDoTexto,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                for (final item in itens) ...[
                  const SizedBox(height: 8),
                  _ItemDeAviso(texto: item, cor: corDoTexto),
                ],
                if (acao != null) ...[
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: acao),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDeAviso extends StatelessWidget {
  final String texto;
  final Color cor;

  const _ItemDeAviso({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(color: cor, fontSize: 14, height: 1.35);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•  ', style: estilo),
        Expanded(child: Text(texto, style: estilo)),
      ],
    );
  }
}

class CaixaAvisoAtencao extends StatelessWidget {
  final String mensagem;
  final List<String> itens;
  final Widget? acao;

  const CaixaAvisoAtencao({
    super.key,
    required this.mensagem,
    this.itens = const [],
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return CaixaAviso(
      icone: Icons.warning_amber_rounded,
      cor: AppCores.aviso,
      corDoTexto: AppCores.aviso,
      mensagem: mensagem,
      itens: itens,
      acao: acao,
    );
  }
}
