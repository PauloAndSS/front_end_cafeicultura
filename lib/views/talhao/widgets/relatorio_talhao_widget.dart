import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/bar_chart.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/pie_chart.dart';

/// Visão agregada dos eventos de um talhão numa safra.
///
/// Só agrega: a lista evento a evento fica com a seção "Atividades" da mesma
/// tela, que já pagina e filtra por status. Duas listas dos mesmos registros,
/// com regras de filtro diferentes, rolando uma sobre a outra, seria pior do
/// que não ter nenhuma.
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

  /// Terrosos, os mesmos do gráfico de tratos do relatório de safra — insumo é
  /// assunto de trato cultural, e a cor mantém a associação entre as telas.
  static const List<Color> _paletaInsumos = [
    Color(0xFFE07B39),
    Color(0xFFB2542C),
    Color(0xFFF2A65A),
    Color(0xFF8C3B1B),
    Color(0xFFF5C08A),
    Color(0xFFD9642F),
  ];

  /// Fatias nomeadas antes de o resto virar "Outros". A legenda do
  /// `PieChartCard` é uma coluna vertical: passar disso estica o card sem
  /// acrescentar leitura.
  static const int _maximoDeInsumosNomeados = 5;

  /// Teto de barras com preenchimento de lacunas no gráfico por mês — um ano,
  /// que é a ordem de grandeza de uma safra.
  static const int _maximoDeMesesContinuos = 12;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF67835C))),
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
          titulo: 'Eventos por mês',
          icone: Icons.bar_chart_rounded,
          valores: _contarPorMes(),
        ),
        const SizedBox(height: 12),
        // O `PieChartCard` se esconde sozinho quando não há dado, e um card
        // que evapora sem explicação parece falha de carga. A nota ocupa o
        // lugar dele dizendo o que de fato aconteceu.
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

  /// Os três estados de [StatusEvento], e não o par concluído/pendente: o
  /// filtro da seção "Atividades", logo abaixo destes cartões, oferece esses
  /// mesmos três — dois vocabulários de status na mesma tela obrigariam o
  /// usuário a traduzir um no outro.
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
          child: _construirCartaoIndicador(
            'Agendados',
            '${porStatus[StatusEvento.agendado]}',
            Icons.event_available,
            const Color(0xFF8FA67E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _construirCartaoIndicador(
            'Em andamento',
            '${porStatus[StatusEvento.emAndamento]}',
            Icons.hourglass_empty,
            Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _construirCartaoIndicador(
            'Finalizados',
            '${porStatus[StatusEvento.finalizado]}',
            Icons.check_circle_outline,
            Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _construirCartaoIndicador(String rotulo, String valor, IconData icone, Color cor) {
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
            Text(
              rotulo,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Contagem de eventos por mês de início, do primeiro ao último mês com
  /// registro.
  ///
  /// Os meses vazios do meio entram com zero de propósito: omiti-los faria
  /// janeiro, fevereiro e dezembro parecerem consecutivos, e a distribuição no
  /// tempo é a única coisa que este gráfico existe para mostrar. O intervalo é
  /// o dos eventos, não o da safra — uma safra de 18 meses geraria 18 barras
  /// ilegíveis num telefone.
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

    // Intervalo largo demais: preencher as lacunas de um talhão com dois
    // eventos separados por três anos daria 37 barras ilegíveis. Aí vale mais
    // mostrar só os meses com registro, mesmo perdendo a noção de distância.
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

  /// Quantas vezes cada insumo foi aplicado — contagem de aplicações, não soma
  /// de quantidade.
  ///
  /// `qtdUsada` vem com medidas incompatíveis entre insumos (`kg`, `l`, `un`,
  /// `m³`): somar 5 kg de adubo com 2 L de defensivo daria um número sem
  /// significado nenhum, e é esse número que a fatia da pizza representaria.
  /// Contar aplicações responde a pergunta que a tela faz — "o que mais se usa
  /// neste talhão?" — e ainda é `int`, que é o que o `PieChartCard` recebe.
  Map<String, int> _contarAplicacoesPorInsumo() {
    final aplicacoes = <String, int>{};

    for (final evento in eventos) {
      if (evento is! TratoCultural) continue;

      // Uma aplicação por trato, mesmo que o insumo apareça em mais de uma
      // linha do evento: contar as linhas mediria o lançamento, não o uso.
      final noEvento = <String>{};

      for (final insumo in evento.insumosUtilizados) {
        final descricao = insumo.descricao.trim();
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
                style: TextStyle(color: Color(0xFF67835C)),
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
