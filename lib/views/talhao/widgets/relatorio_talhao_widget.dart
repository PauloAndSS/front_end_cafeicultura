import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/bar_chart.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/pie_chart.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_grafico.dart';

class RelatorioTalhaoWidget extends StatelessWidget {
  final List<EventoAgricola> eventos;
  final bool isLoading;
  final String? mensagemErro;
  final VoidCallback? onTentarNovamente;

  const RelatorioTalhaoWidget({
    super.key,
    required this.eventos,
    this.isLoading = false,
    this.mensagemErro,
    this.onTentarNovamente,
  });

  static const List<Color> _paletaInsumos = AppCores.paletaTerrosa;

  static const int _maximoDeInsumosNomeados = 5;

  static const int _maximoDeMesesContinuos = 12;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppCores.verdePrimario)),
      );
    }

    if (mensagemErro != null) {
      return _construirErro(mensagemErro!);
    }

    if (eventos.isEmpty) {
      return _construirVazio();
    }

    final insumos = _contarAplicacoesPorInsumo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirIndicadores(),
        const SizedBox(height: 12),
        BarChartCard(
          titulo: 'Atividades por mês',
          icone: Icons.bar_chart_rounded,
          valores: _contarPorMes(),
        ),
        const SizedBox(height: 12),
        if (insumos.isEmpty)
          _construirNota('Nenhum insumo registrado nas atividades desta safra.')
        else
          PieChartCard(
            titulo: 'Insumos mais utilizados',
            icone: Icons.inventory_2_outlined,
            valores: insumos,
            paleta: _paletaInsumos,
          ),
      ],
    );
  }

  Widget _construirNota(String mensagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        mensagem,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _construirIndicadores() {
    final porStatus = <StatusEvento, int>{
      for (final status in StatusEvento.values) status: 0,
    };

    for (final evento in eventos) {
      porStatus[evento.status] = porStatus[evento.status]! + 1;
    }

    return Row(
      children: [
        Expanded(
          child: CartaoIndicador(
                    rotulo: 'Agendados',
                    valor: '${porStatus[StatusEvento.agendado]}',
                    icone: Icons.event_available,
                    cor: AppCores.verdeSecundario,
                  ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CartaoIndicador(
                    rotulo: 'Em andamento',
                    valor: '${porStatus[StatusEvento.emAndamento]}',
                    icone: Icons.hourglass_empty,
                    cor: Colors.orange.shade700,
                  ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CartaoIndicador(
                    rotulo: 'Finalizados',
                    valor: '${porStatus[StatusEvento.finalizado]}',
                    icone: Icons.check_circle_outline,
                    cor: Colors.green.shade700,
                  ),
        ),
      ],
    );
  }

  Map<String, int> _contarPorMes() {
    if (eventos.isEmpty) {
      return const {};
    }

    final mesesComEvento = <DateTime, int>{};

    for (final evento in eventos) {
      final mes = DateTime(evento.dataInicio.year, evento.dataInicio.month);
      mesesComEvento[mes] = (mesesComEvento[mes] ?? 0) + 1;
    }

    final ordenados = mesesComEvento.keys.toList()..sort();
    final primeiro = ordenados.first;
    final ultimo = ordenados.last;

    final mesesNoIntervalo =
        (ultimo.year - primeiro.year) * 12 + (ultimo.month - primeiro.month) + 1;

    if (mesesNoIntervalo > _maximoDeMesesContinuos) {
      return {
        for (final mes in ordenados) formatarMesAbreviado(mes): mesesComEvento[mes]!,
      };
    }

    final contagem = <String, int>{};
    var mesAtual = primeiro;

    while (!mesAtual.isAfter(ultimo)) {
      contagem[formatarMesAbreviado(mesAtual)] = mesesComEvento[mesAtual] ?? 0;
      mesAtual = DateTime(mesAtual.year, mesAtual.month + 1);
    }

    return contagem;
  }

  Map<String, int> _contarAplicacoesPorInsumo() {
    final aplicacoes = <String, int>{};

    for (final evento in eventos) {
      if (evento is! TratoCultural) continue;

      final noEvento = <String>{};

      for (final insumo in evento.insumosUtilizados) {
        final descricao = insumo.insumo.descricao.trim();
        if (descricao.isEmpty) continue;

        noEvento.add(descricao);
      }

      for (final descricao in noEvento) {
        aplicacoes[descricao] = (aplicacoes[descricao] ?? 0) + 1;
      }
    }

    if (aplicacoes.length <= _maximoDeInsumosNomeados) {
      return aplicacoes;
    }

    final ordenados = aplicacoes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final resultado = <String, int>{
      for (final entrada in ordenados.take(_maximoDeInsumosNomeados))
        entrada.key: entrada.value,
    };

    final cauda = ordenados
        .skip(_maximoDeInsumosNomeados)
        .fold<int>(0, (soma, entrada) => soma + entrada.value);

    if (cauda > 0) {
      resultado['Outros'] = cauda;
    }

    return resultado;
  }

  Widget _construirErro(String mensagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          if (onTentarNovamente != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onTentarNovamente,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: AppCores.verdePrimario),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Nenhum evento registrado neste talhão nesta safra.',
          style: TextStyle(fontSize: 14, color: Colors.black45),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
