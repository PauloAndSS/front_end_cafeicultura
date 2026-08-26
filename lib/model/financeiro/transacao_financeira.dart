import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

enum FormaPagamento {
  ted('TED', 'TED'),
  especie('Espécie', 'Espécie'),
  cartaoCredito('Cartão de Crédito', 'Cartão de crédito'),
  cartaoDebito('Cartão de Débito', 'Cartão de débito'),
  cheque('Cheque', 'Cheque'),
  pix('Pix', 'Pix'),
  sacas('Sacas', 'Sacas');

  const FormaPagamento(this.codigoApi, this.rotulo);

  final String codigoApi;

  final String rotulo;

  bool get exigeRepasse => this == FormaPagamento.sacas;

  static FormaPagamento? deCodigo(String? codigo) {
    if (codigo == null) return null;

    final normalizado = codigo.trim().toLowerCase();

    for (final forma in values) {
      if (forma.codigoApi.toLowerCase() == normalizado) return forma;
    }

    return null;
  }
}

enum TipoOperacao {
  monetaria('Monetária', 'Monetária'),
  repasse('Repasse', 'Repasse');

  const TipoOperacao(this.codigoApi, this.rotulo);

  final String codigoApi;

  final String rotulo;

  static TipoOperacao? deCodigo(String? codigo) {
    if (codigo == null) return null;

    final normalizado = codigo.trim().toLowerCase();

    for (final operacao in values) {
      if (operacao.codigoApi.toLowerCase() == normalizado) return operacao;
    }

    return null;
  }
}

abstract class TransacaoFinanceira {
  static const String mensagemCombinacaoInvalida =
      'Repasse é sempre em sacas, e pagamento em sacas só existe em repasse.';

  final int? id;
  final int? idPropriedade;
  final DateTime? dataHoraTransacao;
  final double valor;
  final FormaPagamento formaPagamento;
  final TipoOperacao tipoOperacao;

  TransacaoFinanceira({
    this.id,
    this.idPropriedade,
    this.dataHoraTransacao,
    required this.valor,
    required this.formaPagamento,
    required this.tipoOperacao,
  }) {
    if (!combinacaoValida(formaPagamento, tipoOperacao)) {
      throw ArgumentError(mensagemCombinacaoInvalida);
    }
  }

  TransacaoFinanceira.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        idPropriedade = json['idPropriedade'],
        dataHoraTransacao = lerDataDoJson(json['dataHoraTransacao']),
        valor = lerValorDoJson(json['valor']),
        formaPagamento =
            FormaPagamento.deCodigo(json['formaPagamento']) ??
                FormaPagamento.especie,
        tipoOperacao =
            TipoOperacao.deCodigo(json['tipoOperacao']) ?? TipoOperacao.monetaria;

  static const List<TipoOperacao> operacoesHabilitadas = [
    TipoOperacao.monetaria,
  ];

  static TipoOperacao? get operacaoUnica =>
      operacoesHabilitadas.length == 1 ? operacoesHabilitadas.single : null;

  static bool combinacaoValida(FormaPagamento forma, TipoOperacao operacao) =>
      forma.exigeRepasse == (operacao == TipoOperacao.repasse);

  static List<FormaPagamento> formasPara(TipoOperacao operacao) => FormaPagamento
      .values
      .where((forma) => combinacaoValida(forma, operacao))
      .toList();

  static FormaPagamento? formaUnicaPara(TipoOperacao operacao) {
    final formas = formasPara(operacao);

    return formas.length == 1 ? formas.single : null;
  }

  static double lerValorDoJson(dynamic bruto) {
    if (bruto is num) return bruto.toDouble();
    if (bruto is String) return double.tryParse(bruto) ?? 0.0;

    return 0.0;
  }

  bool get emSacas => formaPagamento == FormaPagamento.sacas;

  String get valorFormatado =>
      emSacas ? '${formatarDecimal(valor)} sacas' : formatarMoeda(valor);

  String? get dataHoraFormatada =>
      dataHoraTransacao == null ? null : formatarDataBr(dataHoraTransacao!);

  Map<String, dynamic> toJson() {
    return {
      if (idPropriedade != null) 'idPropriedade': idPropriedade,
      'valor': valor,
      'formaPagamento': formaPagamento.codigoApi,
      'tipoOperacao': tipoOperacao.codigoApi,
    };
  }
}

extension TotaisDeTransacao on Iterable<TransacaoFinanceira> {
  double get totalMonetario => where((transacao) => !transacao.emSacas)
      .fold(0.0, (soma, transacao) => soma + transacao.valor);

  double get totalEmSacas => where((transacao) => transacao.emSacas)
      .fold(0.0, (soma, transacao) => soma + transacao.valor);

  String get totalFormatado {
    final monetario = totalMonetario;
    final sacas = totalEmSacas;

    if (sacas == 0) return formatarMoeda(monetario);
    if (monetario == 0) return '${formatarDecimal(sacas)} sacas';

    return '${formatarMoeda(monetario)} + ${formatarDecimal(sacas)} sacas';
  }
}
