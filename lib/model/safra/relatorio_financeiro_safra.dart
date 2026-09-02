import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';

/// Uma transação do relatório financeiro da safra, junto com a origem
/// que a gerou (ex: "EVENTO_CONFIRMADO").
class TransacaoRelatorioSafra {
  final String origem;
  final Despesa despesa;

  const TransacaoRelatorioSafra({
    required this.origem,
    required this.despesa,
  });

  factory TransacaoRelatorioSafra.fromJson(Map<String, dynamic> json) {
    final dadosRaw = json['dados'];
    final dados = dadosRaw is Map ? Map<String, dynamic>.from(dadosRaw) : <String, dynamic>{};

    // A API manda a data da transação em `dataHora`, mas
    // `TransacaoFinanceira.fromJson` espera `dataHoraTransacao` — normalizamos
    // aqui para compatibilidade com o model Despesa.
    if (dados.containsKey('dataHora') && !dados.containsKey('dataHoraTransacao')) {
      dados['dataHoraTransacao'] = dados['dataHora'];
    }

    return TransacaoRelatorioSafra(
      origem: json['origem']?.toString() ?? '',
      despesa: Despesa.fromJson(dados),
    );
  }

  /// Rótulo amigável para a origem da transação.
  String get origemFormatada {
    switch (origem) {
      case 'EVENTO_CONFIRMADO':
        return 'Evento confirmado';
      default:
        return origem.isEmpty ? 'Origem não informada' : origem;
    }
  }
}

/// Resposta de `GET /safras/propriedade/{id}/safra/{idSafra}/relatorio-financeiro`.
class RelatorioFinanceiroSafra {
  final num custoTotal;
  final List<TransacaoRelatorioSafra> transacoes;

  const RelatorioFinanceiroSafra({
    required this.custoTotal,
    required this.transacoes,
  });

  static const RelatorioFinanceiroSafra vazio = RelatorioFinanceiroSafra(
    custoTotal: 0,
    transacoes: [],
  );

  factory RelatorioFinanceiroSafra.fromJson(Map<String, dynamic> json) {
    final transacoesRaw = json['transacoes'];
    final transacoes = <TransacaoRelatorioSafra>[];

    if (transacoesRaw is List) {
      for (final item in transacoesRaw) {
        if (item is! Map) continue;

        try {
          transacoes.add(TransacaoRelatorioSafra.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Uma transação malformada não deve derrubar o relatório inteiro.
        }
      }
    }

    final custoRaw = json['custoTotal'];

    return RelatorioFinanceiroSafra(
      custoTotal: custoRaw is num ? custoRaw : (num.tryParse(custoRaw?.toString() ?? '') ?? 0),
      transacoes: transacoes,
    );
  }

  /// Total gasto agrupado pela descrição da despesa (ex: "Diária Capina", "Adubação").
  /// Usado para alimentar o gráfico de pizza "Gastos por descrição".
  Map<String, num> get totalPorDescricao {
    final totais = <String, num>{};
    for (final transacao in transacoes) {
      final chave = transacao.despesa.descricaoTexto;
      totais[chave] = (totais[chave] ?? 0) + transacao.despesa.valor;
    }
    return totais;
  }
}

