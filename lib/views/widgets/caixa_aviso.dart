import 'package:flutter/material.dart';

class CaixaAviso extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final Color corDoTexto;
  final String mensagem;

  const CaixaAviso({
    super.key,
    required this.icone,
    required this.cor,
    required this.corDoTexto,
    required this.mensagem,
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
            child: Text(
              mensagem,
              style: TextStyle(
                color: corDoTexto,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaixaAvisoAtencao extends StatelessWidget {
  final String mensagem;

  const CaixaAvisoAtencao({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return CaixaAviso(
      icone: Icons.warning_amber_rounded,
      cor: Colors.orange,
      corDoTexto: Colors.brown,
      mensagem: mensagem,
    );
  }
}
