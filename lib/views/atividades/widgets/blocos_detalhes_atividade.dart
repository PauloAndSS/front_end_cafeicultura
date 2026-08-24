import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

Color corDoStatus(StatusEvento status) => switch (status) {
      StatusEvento.agendado => AppCores.verdeSecundario,
      StatusEvento.emAndamento => AppCores.verdePrimario,
      StatusEvento.finalizado => Colors.black54,
    };

class BadgeStatusAtividade extends StatelessWidget {
  final EventoAgricola atividade;

  const BadgeStatusAtividade({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(atividade.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        atividade.status.rotulo,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AvisoAtividadeFinalizada extends StatelessWidget {
  final String mensagem;

  const AvisoAtividadeFinalizada({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return CaixaAviso(
      icone: Icons.info_outline,
      cor: Colors.orange,
      corDoTexto: Colors.brown,
      mensagem: mensagem,
    );
  }
}

class AvisoAtividadeAgendada extends StatelessWidget {
  final String dataInicioFormatada;

  const AvisoAtividadeAgendada({
    super.key,
    required this.dataInicioFormatada,
  });

  @override
  Widget build(BuildContext context) {
    return CaixaAviso(
      icone: Icons.event_available,
      cor: AppCores.verdePrimario,
      corDoTexto: Colors.black87,
      mensagem: 'Atividade agendada. Poderá ser confirmada a partir de '
          '$dataInicioFormatada.',
    );
  }
}
