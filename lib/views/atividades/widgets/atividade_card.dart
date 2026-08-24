import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class LinhaInfoCard {
  final IconData icone;
  final String titulo;
  final String valor;

  const LinhaInfoCard({
    required this.icone,
    required this.titulo,
    required this.valor,
  });
}

class AtividadeCard extends StatelessWidget {
  final EventoAgricola atividade;

  final String nomeTalhao;

  final IconData icone;

  final List<LinhaInfoCard> linhasExtras;

  final VoidCallback? onTap;

  const AtividadeCard({
    super.key,
    required this.atividade,
    required this.nomeTalhao,
    required this.icone,
    this.linhasExtras = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: icone,
      titulo: atividade.tituloExibicao,
      onTap: onTap,
      acao: BadgeStatusAtividade(atividade: atividade),
      corpo: [
        LinhaCartao(
          icone: Icons.agriculture,
          titulo: 'Talhão',
          valor: nomeTalhao,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.notes,
          titulo: 'Descrição',
          valor: atividade.descricaoTexto,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LinhaCartao(
                icone: Icons.calendar_today,
                titulo: 'Data de Início',
                valor: atividade.dataInicioFormatada,
              ),
            ),
            Expanded(
              child: LinhaCartao(
                icone: Icons.event_available,
                titulo: 'Data de Término',
                valor: atividade.dataFimFormatada ?? 'Em aberto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.groups_outlined,
          titulo: 'Responsáveis',
          valor: atividade.responsaveisTexto,
        ),
        for (final linha in linhasExtras) ...[
          const SizedBox(height: 12),
          LinhaCartao(
            icone: linha.icone,
            titulo: linha.titulo,
            valor: linha.valor,
          ),
        ],
      ],
    );
  }
}
