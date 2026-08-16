import 'package:flutter/material.dart';

/// Moldura de aviso do app: ícone à esquerda, texto ocupando o resto.
///
/// A cor entra uma vez e se espalha por fundo, borda e ícone — é o que mantém
/// os avisos reconhecíveis como um só elemento em telas diferentes. [corDoTexto]
/// é à parte porque o texto precisa de contraste próprio: o laranja do aviso
/// legível como borda fica ilegível como corpo de frase.
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

/// Aviso de consequência irreversível — o alaranjado que o app já usa para
/// "isto congela o registro".
///
/// Existe como atalho porque a combinação ícone + laranja + marrom se repete em
/// todo aviso desse tipo, e repetir os três a cada uso é o caminho curto para
/// eles divergirem.
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
