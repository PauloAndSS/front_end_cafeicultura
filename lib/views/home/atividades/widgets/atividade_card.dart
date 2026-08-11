import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';

/// Uma linha extra no corpo do card, específica de um tipo de atividade.
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

/// Card de uma atividade agrícola na listagem.
///
/// Tipa contra [EventoAgricola], não contra um tipo concreto: tudo o
/// que ele mostra — título, status, descrição, datas, responsáveis — sai de
/// getters da base.
class AtividadeCard extends StatelessWidget {
  final EventoAgricola atividade;

  /// O payload da listagem não traz o nome do talhão, só o id — quem monta o
  /// card resolve o nome antes.
  final String nomeTalhao;

  final IconData icone;

  /// Vazia para trato cultural. Existe para uma atividade futura pendurar o
  /// que só ela tem (sacas colhidas, umidade final...) sem tocar neste arquivo.
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Material transparente sobre o Container: sem ele o ripple do InkWell
      // seria pintado atrás do fundo branco do card e não apareceria.
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _construirConteudo(),
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: const Color(0xFF8FA67E), size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                atividade.tituloExibicao,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _construirBadgeStatus(),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(color: Color(0xFFE0E0E0), height: 1),
        ),
        _construirLinhaInfo(
          icon: Icons.agriculture,
          titulo: 'Talhão',
          valor: nomeTalhao,
        ),
        const SizedBox(height: 12),
        _construirLinhaInfo(
          icon: Icons.notes,
          titulo: 'Descrição',
          valor: atividade.descricaoTexto,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _construirLinhaInfo(
                icon: Icons.calendar_today,
                titulo: 'Data de Início',
                valor: atividade.dataInicioFormatada,
              ),
            ),
            Expanded(
              child: _construirLinhaInfo(
                icon: Icons.event_available,
                titulo: 'Data de Término',
                valor: atividade.dataFimFormatada ?? 'Em aberto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _construirLinhaInfo(
          icon: Icons.groups_outlined,
          titulo: 'Responsáveis',
          valor: atividade.responsaveisTexto,
        ),
        for (final linha in linhasExtras) ...[
          const SizedBox(height: 12),
          _construirLinhaInfo(
            icon: linha.icone,
            titulo: linha.titulo,
            valor: linha.valor,
          ),
        ],
      ],
    );
  }

  Widget _construirBadgeStatus() {
    final cor =
        atividade.emAndamento ? const Color(0xFF67835C) : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        atividade.statusFormatado,
        style: TextStyle(
          color: cor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirLinhaInfo({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
