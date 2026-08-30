import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/pie_chart.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/relatorio_financeiro_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_relatorio_detalhe_view.dart';

class SafraRelatorioWidget extends StatefulWidget {
  final List<EventoAgricola> eventos;
  final RelatorioFinanceiroSafra? relatorioFinanceiro;
  final bool isLoading;
  final String? mensagemErro;
  final bool mostrarTitulo;

  /// Quando `true`, mostra só os gráficos tocáveis — sem o detalhamento de eventos.
  final bool apenasGraficos;

  final int? idPropriedade;
  final int? idSafra;
  final String Function(int idTalhao)? nomeDoTalhao;

  const SafraRelatorioWidget({
    super.key,
    required this.eventos,
    this.relatorioFinanceiro,
    this.isLoading = false,
    this.mensagemErro,
    this.mostrarTitulo = true,
    this.apenasGraficos = false,
    this.idPropriedade,
    this.idSafra,
    this.nomeDoTalhao,
  });

  @override
  State<SafraRelatorioWidget> createState() => _SafraRelatorioWidgetState();
}

class _SafraRelatorioWidgetState extends State<SafraRelatorioWidget> {
  bool _financeiroExpandido = false;
  bool _tratosExpandido = false;
  bool _talhoesExpandido = false;
  bool _eventosExpandido = false;

  static const List<String> _tiposTratoConhecidos = [
    'Capina',
    'Adubação',
    'Poda',
    'Replantio',
    'Defensivo',
  ];

  static const List<Color> _paletaTratos = AppCores.paletaTerrosa;
  static const List<Color> _paletaTalhoes = AppCores.paletaCiano;
  static const List<Color> _paletaGastos = AppCores.paletaVerde;

  bool get _temDados =>
      widget.eventos.isNotEmpty ||
      (widget.relatorioFinanceiro != null &&
          (widget.relatorioFinanceiro!.custoTotal > 0 || widget.relatorioFinanceiro!.transacoes.isNotEmpty));

  @override
  Widget build(BuildContext context) {
    Widget conteudo;

    if (widget.isLoading) {
      conteudo = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppCores.verdePrimario)),
      );
    } else if (widget.mensagemErro != null) {
      conteudo = _buildMessageCard(widget.mensagemErro!);
    } else if (!_temDados) {
      conteudo = _buildEmptyReportState();
    } else if (widget.apenasGraficos) {
      conteudo = _buildApenasGraficos(context);
    } else {
      conteudo = _buildRelatorioCompleto(context);
    }

    if (!widget.mostrarTitulo) {
      return conteudo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relatório da safra',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppCores.verdePrimario,
          ),
        ),
        const SizedBox(height: 12),
        conteudo,
      ],
    );
  }

  /// Modo compacto: apenas os gráficos tocáveis
  Widget _buildApenasGraficos(BuildContext context) {
    final temTratos = widget.eventos.any((e) => e is TratoCultural);
    final temTalhoes = widget.eventos.isNotEmpty;
    final temGastos = (widget.relatorioFinanceiro?.totalPorDescricao.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (temTratos) ...[
          // Sem sanfona neste modo, então o título do gráfico continua visível.
          _buildGraficoTocavel(context, _buildGraficoPorTipoTrato()),
          const SizedBox(height: 12),
        ],
        if (temTalhoes) ...[
          _buildGraficoTocavel(context, _buildGraficoPorTalhao()),
          const SizedBox(height: 12),
        ],
        if (temGastos) ...[
          _buildGraficoTocavel(context, _buildGraficoGastosPorDescricao()),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: () => _abrirRelatorioCompleto(context),
            icon: const Icon(Icons.open_in_new, size: 16, color: AppCores.verdePrimario),
            label: const Text('Ver relatório completo', style: TextStyle(color: AppCores.verdePrimario)),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoTocavel(BuildContext context, Widget grafico) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _abrirRelatorioCompleto(context),
      child: grafico,
    );
  }

  void _abrirRelatorioCompleto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SafraRelatorioDetalheView(
          eventos: widget.eventos,
          relatorioFinanceiro: widget.relatorioFinanceiro,
          idPropriedade: widget.idPropriedade,
          idSafra: widget.idSafra,
          nomeDoTalhao: widget.nomeDoTalhao,
        ),
      ),
    );
  }

  /// Relatório de Manejo completo, expansível com os detalhes do Relatório Financeiro
  Widget _buildRelatorioCompleto(BuildContext context) {
    final concluidos = widget.eventos.where((e) => e.finalizado).toList();
    final pendentes = widget.eventos.where((e) => !e.finalizado).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Relatório de Resumo de Eventos (Manejo) — sempre visível
        if (widget.eventos.isNotEmpty) ...[
          _buildResumoRelatorio(),
          const SizedBox(height: 14),
        ],

        // 2. Relatório de Tratos por Tipo (Manejo) — sanfona
        // O título já aparece no cabeçalho da sanfona, então o gráfico
        // interno é renderizado sem o próprio título (mostrarTitulo: false).
        if (widget.eventos.any((e) => e is TratoCultural))
          _buildSanfona(
            titulo: 'Tratos por tipo',
            icone: Icons.eco_outlined,
            expandido: _tratosExpandido,
            aoAlternar: () => setState(() => _tratosExpandido = !_tratosExpandido),
            conteudo: _buildGraficoPorTipoTrato(mostrarTitulo: false),
          ),

        // 3. Relatório de Eventos por Talhão (Manejo) — sanfona
        if (widget.eventos.isNotEmpty)
          _buildSanfona(
            titulo: 'Eventos por talhão',
            icone: Icons.grid_view_rounded,
            expandido: _talhoesExpandido,
            aoAlternar: () => setState(() => _talhoesExpandido = !_talhoesExpandido),
            conteudo: _buildGraficoPorTalhao(mostrarTitulo: false),
          ),

        // 4. Relatório Financeiro — sanfona
        _buildSanfona(
          titulo: 'Relatório Financeiro da Safra',
          icone: Icons.monetization_on_outlined,
          expandido: _financeiroExpandido,
          aoAlternar: () => setState(() => _financeiroExpandido = !_financeiroExpandido),
          conteudo: _buildSecaoFinanceira(),
        ),

        // 5. Eventos detalhados — sanfona
        if (widget.eventos.isNotEmpty)
          _buildSanfona(
            titulo: 'Eventos detalhados',
            icone: Icons.list_alt_rounded,
            expandido: _eventosExpandido,
            aoAlternar: () => setState(() => _eventosExpandido = !_eventosExpandido),
            conteudo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubtituloGrupoEventos('Pendentes', pendentes.length, Colors.orange.shade700),
                const SizedBox(height: 8),
                if (pendentes.isEmpty)
                  _buildAvisoGrupoVazio('Nenhum evento pendente.')
                else
                  ...pendentes.map(_buildEventCard),
                const SizedBox(height: 16),
                _buildSubtituloGrupoEventos('Concluídos', concluidos.length, Colors.green.shade700),
                const SizedBox(height: 8),
                if (concluidos.isEmpty)
                  _buildAvisoGrupoVazio('Nenhum evento concluído ainda.')
                else
                  ...concluidos.map(_buildEventCard),
              ],
            ),
          ),
      ],
    );
  }

  /// Widget reutilizável de sanfona (efeito acordeão)
  Widget _buildSanfona({
    required String titulo,
    required IconData icone,
    required bool expandido,
    required VoidCallback aoAlternar,
    required Widget conteudo,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: aoAlternar,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(icone, color: AppCores.verdePrimario),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppCores.verdePrimario,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expandido ? Icons.expand_less : Icons.expand_more,
                    color: AppCores.verdePrimario,
                  ),
                ],
              ),
            ),
          ),
          if (expandido)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: conteudo,
            ),
        ],
      ),
    );
  }

  Widget _buildSubtituloGrupoEventos(String titulo, int quantidade, Color cor) {
    return Row(
      children: [
        Text(
          titulo,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cor),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$quantidade',
            style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoGrupoVazio(String mensagem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        mensagem,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
      ),
    );
  }

  // 1. Resumo dos Eventos (Cards de indicadores)
  Widget _buildResumoRelatorio() {
    final total = widget.eventos.length;
    final finalizados = widget.eventos.where((e) => e.status == StatusEvento.finalizado).length;
    final emAndamento = widget.eventos.where((e) => e.status == StatusEvento.emAndamento).length;
    final agendados = widget.eventos.where((e) => e.status == StatusEvento.agendado).length;

    return Row(
      children: [
        Expanded(
          child: _buildEstatisticaCard('Total', '$total', Icons.event_note_outlined, AppCores.verdePrimario),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEstatisticaCard('Finalizados', '$finalizados', Icons.check_circle_outline, Colors.green.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEstatisticaCard('Em andamento', '$emAndamento', Icons.hourglass_empty, Colors.orange.shade700),
        ),
        if (agendados > 0) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildEstatisticaCard('Agendados', '$agendados', Icons.event_available, AppCores.verdeSecundario),
          ),
        ],
      ],
    );
  }

  Widget _buildEstatisticaCard(String rotulo, String valor, IconData icone, Color cor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 20),
            const SizedBox(height: 4),
            Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 2),
            Text(
              rotulo,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 2. Gráfico: Tratos por tipo
  Widget _buildGraficoPorTipoTrato({bool mostrarTitulo = true}) {
    final contagem = <String, int>{for (final tipo in _tiposTratoConhecidos) tipo: 0};
    var outros = 0;

    for (final evento in widget.eventos) {
      if (evento is! TratoCultural) continue;
      final tipo = evento.tipoTrato.descricao;
      if (tipo.isEmpty || tipo == 'Não informado') continue;

      if (contagem.containsKey(tipo)) {
        contagem[tipo] = contagem[tipo]! + 1;
      } else {
        outros++;
      }
    }

    if (outros > 0) {
      contagem['Outro'] = outros;
    }
    contagem.removeWhere((_, valor) => valor == 0);

    if (contagem.isEmpty) return const SizedBox.shrink();

    return PieChartCard(
      titulo: 'Tratos por tipo',
      icone: Icons.eco_outlined,
      valores: contagem,
      paleta: _paletaTratos,
      mostrarTitulo: mostrarTitulo,
    );
  }

  // 3. Gráfico: Eventos por talhão
  Widget _buildGraficoPorTalhao({bool mostrarTitulo = true}) {
    final contagem = <int, int>{};
    for (final evento in widget.eventos) {
      final idTalhao = evento.idTalhao;
      contagem[idTalhao] = (contagem[idTalhao] ?? 0) + 1;
    }

    if (contagem.isEmpty) return const SizedBox.shrink();

    final talhoesOrdenados = contagem.keys.toList()..sort();
    final valoresPorNome = <String, int>{
      for (final id in talhoesOrdenados)
        (widget.nomeDoTalhao?.call(id) ?? 'Talhão $id'): contagem[id]!,
    };

    return PieChartCard(
      titulo: 'Eventos por talhão',
      icone: Icons.grid_view_rounded,
      valores: valoresPorNome,
      paleta: _paletaTalhoes,
      mostrarTitulo: mostrarTitulo,
    );
  }

  // 4. Gráfico / Resumo financeiro
  Widget _buildGraficoGastosPorDescricao({bool mostrarTitulo = true}) {
    final totais = widget.relatorioFinanceiro?.totalPorDescricao ?? const {};
    if (totais.isEmpty) return const SizedBox.shrink();

    final valoresEmCentavos = totais.map(
      (chave, valor) => MapEntry(chave, (valor * 100).round()),
    );

    return PieChartCard(
      titulo: 'Gastos por descrição',
      icone: Icons.pie_chart_outline,
      valores: valoresEmCentavos,
      paleta: _paletaGastos,
      valorFormatador: (centavos) => formatarMoeda(centavos / 100),
      mostrarTitulo: mostrarTitulo,
    );
  }

  Widget _buildSecaoFinanceira() {
    if (widget.relatorioFinanceiro != null) {
      return RelatorioFinanceiroWidget(
        relatorio: widget.relatorioFinanceiro,
        mostrarTitulo: false,
      );
    }

    if (widget.idPropriedade != null && widget.idSafra != null) {
      return RelatorioFinanceiroWidget(
        idPropriedade: widget.idPropriedade,
        idSafra: widget.idSafra,
        mostrarTitulo: false,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEventCard(EventoAgricola evento) {
    final isConcluido = evento.finalizado;
    final dataInicioTexto = formatarDataBr(evento.dataInicio);
    final dataFimTexto = evento.dataFim != null ? formatarDataBr(evento.dataFim!) : null;
    final talhaoTexto = widget.nomeDoTalhao?.call(evento.idTalhao) ?? 'Talhão ${evento.idTalhao}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    evento.tituloExibicao,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isConcluido ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isConcluido ? 'Finalizado' : 'Em andamento',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isConcluido ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(talhaoTexto),
            Text(
              dataFimTexto != null
                  ? 'Período: $dataInicioTexto até $dataFimTexto'
                  : 'Data: $dataInicioTexto',
            ),
            if (evento.descricao != null && evento.descricao!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(evento.descricao!),
            ],
            if (evento.responsaveis.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Responsável: ${evento.responsaveisTexto}'),
            ],
            if (evento is TratoCultural && evento.insumosUtilizados.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Insumos utilizados:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...evento.insumosUtilizados.map(
                (insumo) => Text('• ${insumo.descricaoComQuantidade}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyReportState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 44, color: AppCores.verdeSecundario),
              SizedBox(height: 12),
              Text(
                'Nada registrado nessa Safra ainda, registre mais dados e os relatórios aparecerão por aqui!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}