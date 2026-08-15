import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart'; 
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/pie_chart.dart';

class SafraRelatorioWidget extends StatelessWidget {
  final List<EventoAgricola> eventos;
  final bool isLoading;
  final String? mensagemErro;
  final bool mostrarTitulo;

  const SafraRelatorioWidget({
    super.key,
    required this.eventos,
    this.isLoading = false,
    this.mensagemErro,
    this.mostrarTitulo = true,
  });

  static const List<String> _tiposTratoConhecidos = [
    'Capina',
    'Adubação',
    'Poda',
    'Replantio',
    'Defensivo',
  ];

  static const List<Color> _paletaTratos = [
    Color(0xFFE07B39),
    Color(0xFFB2542C),
    Color(0xFFF2A65A),
    Color(0xFF8C3B1B),
    Color(0xFFF5C08A),
    Color(0xFFD9642F),
  ];

  static const List<Color> _paletaTalhoes = [
    Color(0xFF2E6E7A),
    Color(0xFF4F98A6),
    Color(0xFF7FC1CC),
    Color(0xFF1D4C55),
    Color(0xFFB8DEE3),
    Color(0xFF3A8492),
  ];

  static const List<Color> _paletaGastos = [
    Color(0xFF4C6B3A),
    Color(0xFF7A9A5C),
    Color(0xFFA9C08A),
    Color(0xFF335229),
    Color(0xFFC7D9A9),
    Color(0xFF5D8A4F),
  ];

  @override
  Widget build(BuildContext context) {
    Widget conteudo;

    if (isLoading) {
      conteudo = const Center(child: CircularProgressIndicator());
    } else if (mensagemErro != null) {
      conteudo = _buildMessageCard(mensagemErro!);
    } else if (eventos.isEmpty) {
      conteudo = _buildEmptyReportState();
    } else {
      conteudo = _buildRelatorioCompleto(eventos);
    }

    if (!mostrarTitulo) {
      return conteudo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relatório da safra',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF67835C)),
        ),
        const SizedBox(height: 8),
        conteudo,
      ],
    );
  }

  Widget _buildRelatorioCompleto(List<EventoAgricola> eventos) {
    final concluidos = eventos.where((e) => e.dataFim != null).toList();
    final pendentes = eventos.where((e) => e.dataFim == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResumoRelatorio(eventos),
        const SizedBox(height: 12),
        _buildResumoFinanceiro(eventos),
        const SizedBox(height: 12),
        _buildGraficoPorTipoTrato(eventos),
        const SizedBox(height: 12),
        _buildGraficoPorTalhao(eventos),
        const SizedBox(height: 12),
        _buildGraficoGastosPorCategoria(eventos),
        const SizedBox(height: 20),
        const Text(
          'Eventos detalhados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF67835C)),
        ),
        const SizedBox(height: 12),
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
            color: cor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('$quantidade', style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.bold)),
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

  Widget _buildResumoRelatorio(List<EventoAgricola> eventos) {
    final total = eventos.length;
    final concluidos = eventos.where((e) => e.dataFim != null).length;
    final pendentes = total - concluidos;

    return Row(
      children: [
        Expanded(
          child: _buildEstatisticaCard('Eventos', '$total', Icons.event_note_outlined, const Color(0xFF67835C)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildEstatisticaCard('Concluídos', '$concluidos', Icons.check_circle_outline, Colors.green.shade700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildEstatisticaCard('Pendentes', '$pendentes', Icons.hourglass_empty, Colors.orange.shade700),
        ),
      ],
    );
  }

  Widget _buildEstatisticaCard(String rotulo, String valor, IconData icone, Color cor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 22),
            const SizedBox(height: 6),
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 2),
            Text(rotulo, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  static String _formatarMoeda(num valor) {
    final negativo = valor < 0;
    final absoluto = valor.abs();
    final inteiro = absoluto.truncate();
    final centavos = ((absoluto - inteiro) * 100).round();
    final inteiroTexto = inteiro.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    final texto = 'R\$ $inteiroTexto,${centavos.toString().padLeft(2, '0')}';
    return negativo ? '-$texto' : texto;
  }
  List<dynamic> _extrairTransacoes(List<EventoAgricola> eventos) {
    return eventos.expand((e) {
      try {
        return (e as dynamic).transacoesFinanceiras as Iterable<dynamic>? ?? [];
      } catch (_) {
        return [];
      }
    }).toList();
  }

  Widget _buildResumoFinanceiro(List<EventoAgricola> eventos) {
    final transacoes = _extrairTransacoes(eventos);
    if (transacoes.isEmpty) return const SizedBox.shrink();

    final receitaTotal = transacoes.where((t) => t.isReceita).fold<num>(0, (soma, t) => soma + t.valor);
    final despesaTotal = transacoes.where((t) => t.isDespesa).fold<num>(0, (soma, t) => soma + t.valor);
    final saldo = receitaTotal - despesaTotal;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.payments_outlined, size: 18, color: Color(0xFF67835C)),
                SizedBox(width: 6),
                Text(
                  'Resumo financeiro da safra',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF67835C)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildEstatisticaCard(
                    'Receita total',
                    _formatarMoeda(receitaTotal),
                    Icons.trending_up,
                    Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildEstatisticaCard(
                    'Despesa total',
                    _formatarMoeda(despesaTotal),
                    Icons.trending_down,
                    Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildEstatisticaCard(
                    'Saldo líquido',
                    _formatarMoeda(saldo),
                    Icons.account_balance_wallet_outlined,
                    saldo >= 0 ? const Color(0xFF67835C) : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildGraficoGastosPorCategoria(List<EventoAgricola> eventos) {
    final despesas = _extrairTransacoes(eventos).where((t) => t.isDespesa && t.valor > 0).toList();
    if (despesas.isEmpty) return const SizedBox.shrink();
    final totaisPorCategoria = <String, int>{};
    for (final despesa in despesas) {
      final categoria = despesa.categoria.isNotEmpty ? despesa.categoria : 'Outros';
      final int valorAtual = totaisPorCategoria[categoria] ?? 0;
      final int centavosAdicionais = ((despesa.valor as num) * 100).round();
      totaisPorCategoria[categoria] = valorAtual + centavosAdicionais;
    }
    return PieChartCard(
      titulo: 'Gastos por categoria',
      icone: Icons.pie_chart_outline,
      valores: totaisPorCategoria,
      paleta: _paletaGastos,
    );
  }

  Widget _buildGraficoPorTipoTrato(List<EventoAgricola> eventos) {
    final contagem = <String, int>{for (final tipo in _tiposTratoConhecidos) tipo: 0};
    var outros = 0;
    for (final evento in eventos) {
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
    return PieChartCard(
      titulo: 'Tratos por tipo',
      icone: Icons.eco_outlined,
      valores: contagem,
      paleta: _paletaTratos,
    );
  }

  Widget _buildGraficoPorTalhao(List<EventoAgricola> eventos) {
    final contagem = <int, int>{};
    final nomesTalhoes = <int, String>{};
    for (final evento in eventos) {
      final idTalhao = evento.idTalhao; 
      contagem[idTalhao] = (contagem[idTalhao] ?? 0) + 1;
      nomesTalhoes[idTalhao] = 'Talhão $idTalhao';
    }
    if (contagem.isEmpty) return const SizedBox.shrink();

    final talhoesOrdenados = contagem.keys.toList()..sort();
    final valoresPorNome = <String, int>{
      for (final id in talhoesOrdenados) (nomesTalhoes[id] ?? 'Talhão $id'): contagem[id]!,
    };
    return PieChartCard(
      titulo: 'Eventos por talhão',
      icone: Icons.grid_view_rounded,
      valores: valoresPorNome,
      paleta: _paletaTalhoes,
    );
  }
  
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Widget _buildEventCard(EventoAgricola evento) {
    final isConcluido = evento.dataFim != null;
    final dataInicioTexto = _formatarData(evento.dataInicio); 
    final dataFimTexto = evento.dataFim != null ? _formatarData(evento.dataFim!) : null;
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
                    // `tituloExibicao` é um getter real (não-nulo) da
                    // classe base `Evento`, sobrescrito por `TratoCultural`
                    // — não precisa mais do cast dinâmico com fallback.
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
                    isConcluido ? 'Concluído' : 'Em andamento',
                    style: TextStyle(
                      fontSize: 11,
                      color: isConcluido ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Talhão: ${evento.idTalhao}'),
            Text(dataFimTexto != null ? 'Período: $dataInicioTexto até $dataFimTexto' : 'Data: $dataInicioTexto',),
            if (evento.descricao != null && evento.descricao!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(evento.descricao!),
            ],
            if (evento.responsaveis.isNotEmpty) ...[
              const SizedBox(height: 6),
              // `responsaveisTexto` já vem pronto de `Evento` (junta os
              // nomes de exibição de cada `Pessoa`) — sem cast dinâmico.
              Text('Responsável: ${evento.responsaveisTexto}'),
            ],
            
            if (evento is TratoCultural && evento.insumosUtilizados.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Insumos utilizados:', style: TextStyle(fontWeight: FontWeight.w600)),
              // `InsumoUtilizado` (model/insumos/insumo_utilizado.dart) não
              // tem um getter `textoQuantidade` — os campos reais são
              // `descricao` e `qtdFormatada` (ou `descricaoComQuantidade`
              // já pronto com os dois juntos).
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.description_outlined, size: 44, color: Color(0xFF8FA67E)),
              const SizedBox(height: 12),
              const Text(
                'Nada registrado nessa Safra ainda, registre mais dados e os relatórios aparecerão por aqui!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}