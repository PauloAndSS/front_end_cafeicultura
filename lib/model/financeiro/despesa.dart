import 'package:frond_end_cafeicultura_mobile/model/financeiro/transacao_financeira.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

export 'package:frond_end_cafeicultura_mobile/model/financeiro/transacao_financeira.dart';

class Despesa extends TransacaoFinanceira {
  final String? descricao;
  final Pessoa? beneficiado;
  final int? idEvento;

  Despesa({
    super.id,
    super.idPropriedade,
    super.dataHoraTransacao,
    required super.valor,
    required super.formaPagamento,
    required super.tipoOperacao,
    this.descricao,
    this.beneficiado,
    this.idEvento,
  });

  Despesa.fromJson(super.json)
      : descricao = json['descricao'],
        beneficiado = _lerBeneficiado(json['beneficiado']),
        idEvento = json['idEvento'],
        super.fromJson();

  String get descricaoTexto {
    final texto = descricao?.trim() ?? '';
    return texto.isEmpty ? 'Sem descrição' : texto;
  }

  String get beneficiadoTexto =>
      beneficiado?.nomeParaExibicao ?? 'Sem beneficiado';

  Despesa comEvento(int idEvento) {
    return Despesa(
      id: id,
      idPropriedade: idPropriedade,
      dataHoraTransacao: dataHoraTransacao,
      valor: valor,
      formaPagamento: formaPagamento,
      tipoOperacao: tipoOperacao,
      descricao: descricao,
      beneficiado: beneficiado,
      idEvento: idEvento,
    );
  }

  String get resumo => '${formaPagamento.rotulo} — $valorFormatado';

  String get resumoComBeneficiado =>
      beneficiado == null ? resumo : '$resumo · ${beneficiado!.nomeParaExibicao}';

  @override
  Map<String, dynamic> toJson() {
    final descricaoLimpa = descricao?.trim() ?? '';

    return {
      ...super.toJson(),
      if (idEvento != null) 'idEvento': idEvento,
      if (beneficiado?.id != null) 'beneficiado': beneficiado!.id,
      if (descricaoLimpa.isNotEmpty) 'descricao': descricaoLimpa,
    };
  }

  static Pessoa? _lerBeneficiado(dynamic bruto) {
    if (bruto is! Map<String, dynamic>) return null;

    try {
      final pessoa = PessoaFactory.fromJson(bruto);
      return pessoa.id == null ? null : pessoa;
    } catch (_) {
      return null;
    }
  }
}

extension ResumoDeDespesas on Iterable<Despesa> {
  String get contagemComTotal => '$length despesa(s) — Total: $totalFormatado';
}
