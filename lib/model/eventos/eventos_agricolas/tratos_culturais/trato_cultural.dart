import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';

export 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';

class TipoTrato {
  final String descricao;

  TipoTrato(this.descricao);

  factory TipoTrato.fromJson(Map<String, dynamic> json) {
    return TipoTrato(json['descricao'] ?? '');
  }

  @override
  bool operator ==(Object other) =>
      other is TipoTrato && other.descricao == descricao;

  @override
  int get hashCode => descricao.hashCode;
}

class TratoCultural extends EventoAgricola {
  final TipoTrato tipoTrato;
  final List<InsumoUtilizado> insumosUtilizados;

  TratoCultural({
    super.id,
    required super.dataInicio,
    super.dataFim,
    super.descricao,
    super.dataCadastro,
    required super.idTalhao,
    super.idSafra,
    super.responsaveis,
    super.transacoesFinanceiras,
    required this.tipoTrato,
    this.insumosUtilizados = const [],
  });

  TratoCultural.fromJson(super.json)
      : tipoTrato = TipoTrato(json['tipoTrato'] ?? 'Não informado'),
        insumosUtilizados = _lerInsumos(json),
        super.fromJson();

  @override
  String get tituloExibicao => tipoTrato.descricao;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tipoTrato': tipoTrato.descricao,
      'insumosUtilizados':
          insumosUtilizados.map((insumo) => insumo.toJson()).toList(),
    };
  }

  // dinâmica para retorno do PATCH não precisar instanciar um novo objeto inteiro
  TratoCultural copyWith({
    int? id,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    DateTime? dataCadastro,
    int? idTalhao,
    int? idSafra,
    List<Pessoa>? responsaveis,
    List<TransacaoFinanceira>? transacoesFinanceiras,
    TipoTrato? tipoTrato,
    List<InsumoUtilizado>? insumosUtilizados,
  }) {
    return TratoCultural(
      id: id ?? this.id,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      descricao: descricao ?? this.descricao,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      idTalhao: idTalhao ?? this.idTalhao,
      idSafra: idSafra ?? this.idSafra,
      responsaveis: responsaveis ?? this.responsaveis,
      transacoesFinanceiras:
          transacoesFinanceiras ?? this.transacoesFinanceiras,
      tipoTrato: tipoTrato ?? this.tipoTrato,
      insumosUtilizados: insumosUtilizados ?? this.insumosUtilizados,
    );
  }

  static List<InsumoUtilizado> _lerInsumos(Map<String, dynamic> json) {
    final lista = json['insumosUtilizados'] ?? json['insumos'];

    if (lista is! List) return const [];

    return lista
        .whereType<Map<String, dynamic>>()
        .map((insumo) => InsumoUtilizado.fromJson(insumo))
        .toList();
  }
}
