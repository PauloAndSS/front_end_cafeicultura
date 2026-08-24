import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class TalhaoCard extends StatelessWidget {
  final Talhao talhao;
  final VoidCallback? onTap;

  const TalhaoCard({super.key, required this.talhao, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: Icons.agriculture,
      titulo: talhao.nomeExibicao,
      onTap: onTap,
      acao: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (talhao.encerrado)
            const BadgeTexto(
              texto: 'Encerrado',
              cor: Colors.red,
              margem: EdgeInsets.only(right: 8),
            ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
        ],
      ),
      corpo: [
        LinhaCartao(
          icone: Icons.square_foot,
          titulo: 'Tamanho',
          valor: talhao.tamanhoFormatado,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.eco_outlined,
          titulo: 'Espécie',
          valor: talhao.especieFormatada,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.category_outlined,
          titulo: 'Variedades de Café',
          valor: talhao.variedadesTexto,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LinhaCartao(
                icone: Icons.grass,
                titulo: 'Pés de Café',
                valor: talhao.qtdPeCafeFormatada,
              ),
            ),
            Expanded(
              child: LinhaCartao(
                icone: Icons.calendar_today,
                titulo: 'Data de Início',
                valor: talhao.dataInicioFormatada,
              ),
            ),
          ],
        ),
        if (talhao.dataFimFormatada != null) ...[
          const SizedBox(height: 12),
          LinhaCartao(
            icone: Icons.event_available,
            titulo: 'Data de Encerramento',
            valor: talhao.dataFimFormatada!,
          ),
        ],
      ],
    );
  }
}
