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

double? _paraDoubleOuNulo(dynamic valor) {
  if (valor is num) return valor.toDouble();
  if (valor is String) return double.tryParse(valor);

  return null;
}

/// Linha do catálogo de insumos de um proprietário.
class Insumo {

  final int? id;
  final String descricao;
  final MedidaInsumo medida;
  final double? qtdEstoque;

  Insumo({
    this.id,
    required this.descricao,
    required this.medida,
    this.qtdEstoque,
  });

  String get unidadeFormatada => medida.rotulo;

  String get saldoFormatado {
    final saldo = qtdEstoque;

    if (saldo == null) return 'Saldo não informado';

    return '${formatarDecimal(saldo)} ${medida.sigla}';
  }

  Insumo comSaldo(double? novoSaldo) => Insumo(
        id: id,
        descricao: descricao,
        medida: medida,
        qtdEstoque: novoSaldo,
      );

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
      qtdEstoque: _paraDoubleOuNulo(json['qtdEstoque']),
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
      qtdUsada: _paraDoubleOuNulo(json['qtdUsada'] ?? json['quantidade']) ?? 0.0,
    );
  }

  @override
  String toString() => descricaoComQuantidade;
}

extension ResumoDeInsumosUtilizados on Iterable<InsumoUtilizado> {
  String get contagem => contarItens(length, 'insumo', 'insumos');
}
