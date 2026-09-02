import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_relatorio.dart';

/// Página de detalhe do relatório da safra.
///
/// Mostra o relatório completo (indicadores de eventos, os gráficos por tipo e
/// por talhão, o relatório financeiro e a lista de eventos detalhada).
class SafraRelatorioDetalheView extends StatelessWidget {
  final List<EventoAgricola> eventos;
  final RelatorioFinanceiroSafra? relatorioFinanceiro;
  final int? idPropriedade;
  final int? idSafra;
  final String Function(int idTalhao)? nomeDoTalhao;

  const SafraRelatorioDetalheView({
    super.key,
    required this.eventos,
    this.relatorioFinanceiro,
    this.idPropriedade,
    this.idSafra,
    this.nomeDoTalhao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        title: const Text('Relatório da safra'),
        backgroundColor: AppCores.verdeSecundario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafraRelatorioWidget(
          eventos: eventos,
          relatorioFinanceiro: relatorioFinanceiro,
          idPropriedade: idPropriedade,
          idSafra: idSafra,
          nomeDoTalhao: nomeDoTalhao,
          mostrarTitulo: false,
        ),
      ),
    );
  }
}
