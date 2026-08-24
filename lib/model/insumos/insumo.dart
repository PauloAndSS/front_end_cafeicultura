import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

enum MedidaInsumo {
  unidade('un', 'Unidade (un)'),
  quilograma('kg', 'Quilograma (kg)'),
  grama('g', 'Grama (g)'),
  miligrama('mg', 'Miligrama (mg)'),
  litro('l', 'Litro (l)'),
  mililitro('ml', 'Mililitro (ml)'),
  metroCubico('m3', 'Metro cúbico (m³)');

  const MedidaInsumo(this.sigla, this.rotulo);

  final String sigla;

  final String rotulo;
  static MedidaInsumo? deSigla(String? sigla) {
    if (sigla == null) return null;

    final normalizada = sigla.trim().toLowerCase();

    for (final medida in MedidaInsumo.values) {
      if (medida.sigla == normalizada) return medida;
    }

    return null;
  }
}

/// Linha do catálogo de insumos de um proprietário.
class Insumo {

  final int? id;
  final String descricao;
  final MedidaInsumo medida;

  Insumo({this.id, required this.descricao, required this.medida});

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'medida': medida.sigla,
    };
  }

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'],
      descricao: json['descricao'] ?? 'Sem descrição',
      medida: MedidaInsumo.deSigla(json['medida']) ?? MedidaInsumo.unidade,
    );
  }

  @override
  String toString() => descricao;
}

/// Quanto de um insumo um evento consumiu.
class InsumoUtilizado {
  final Insumo insumo;

  final double qtdUsada;

  const InsumoUtilizado({required this.insumo, required this.qtdUsada});

  int get idInsumo => insumo.id!;

  String get qtdFormatada =>
      '${formatarDecimal(qtdUsada)} ${insumo.medida.sigla}';

  String get descricaoComQuantidade => '${insumo.descricao} — $qtdFormatada';

  Map<String, dynamic> toJson() => {'idInsumo': idInsumo, 'qtdUsada': qtdUsada};

  factory InsumoUtilizado.fromJson(Map<String, dynamic> json) {
    final aninhado = json['insumo'];

    return InsumoUtilizado(
      insumo: Insumo.fromJson(
        aninhado is Map<String, dynamic> ? aninhado : json,
      ),
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
