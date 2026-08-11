import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:intl/intl.dart';

export 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';

// Insumo com a quantidade gasta.
class InsumoUtilizado {
  final int idInsumo;
  final String descricao;
  final MedidaInsumo? medida;
  final double qtdUsada;

  InsumoUtilizado({
    required this.idInsumo,
    required this.descricao,
    this.medida,
    required this.qtdUsada,
  });

  String get qtdFormatada {
    final quantidade = NumberFormat.decimalPattern('pt_BR').format(qtdUsada);
    final sigla = medida?.sigla;

    return sigla == null ? quantidade : '$quantidade $sigla';
  }

  String get descricaoComQuantidade => '$descricao — $qtdFormatada';

  Map<String, dynamic> toJson() {
    return {'idInsumo': idInsumo, 'qtdUsada': qtdUsada};
  }

  InsumoUtilizado copyWith({double? qtdUsada}) {
    return InsumoUtilizado(
      idInsumo: idInsumo,
      descricao: descricao,
      medida: medida,
      qtdUsada: qtdUsada ?? this.qtdUsada,
    );
  }

  factory InsumoUtilizado.fromJson(Map<String, dynamic> json) {
    final aninhado = json['insumo'] is Map<String, dynamic>
        ? json['insumo'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return InsumoUtilizado(
      idInsumo: json['idInsumo'] ?? aninhado['id'] ?? 0,
      descricao:
          json['descricao'] ?? aninhado['descricao'] ?? 'Insumo sem descrição',
      medida: MedidaInsumo.deSigla(json['medida'] ?? aninhado['medida']),
      qtdUsada: _paraDouble(json['qtdUsada'] ?? json['quantidade']),
    );
  }

  static double _paraDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() => descricaoComQuantidade;
}
