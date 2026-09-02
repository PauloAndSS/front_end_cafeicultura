import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

export 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';

sealed class CompraDeInsumos {
  final Insumo insumo;
  final Despesa despesa;
  final double qtdComprada;

  const CompraDeInsumos._({
    required this.insumo,
    required this.despesa,
    required this.qtdComprada,
  });

  factory CompraDeInsumos.novoInsumo({
    required Insumo insumo,
    required Despesa despesa,
    required double qtdComprada,
  }) = CompraDeInsumoNovo;

  factory CompraDeInsumos.insumoExistente({
    required Insumo insumo,
    required Despesa despesa,
    required double qtdComprada,
  }) = CompraDeInsumoExistente;

  Map<String, dynamic> get referenciaDoInsumo;

  bool get conflitaPorDescricao;

  String get qtdFormatada =>
      '${formatarDecimal(qtdComprada)} ${insumo.medida.sigla}';

  String get descricaoComQuantidade => '${insumo.descricao} — $qtdFormatada';

  Map<String, dynamic> toJson() {
    return {
      ...referenciaDoInsumo,
      ...despesa.toJson(),
      'qtdComprada': qtdComprada,
    };
  }
}

final class CompraDeInsumoNovo extends CompraDeInsumos {
  CompraDeInsumoNovo({
    required super.insumo,
    required super.despesa,
    required super.qtdComprada,
  }) : super._();

  @override
  Map<String, dynamic> get referenciaDoInsumo => {'novoInsumo': insumo.toJson()};

  @override
  bool get conflitaPorDescricao => true;
}

final class CompraDeInsumoExistente extends CompraDeInsumos {
  CompraDeInsumoExistente({
    required super.insumo,
    required super.despesa,
    required super.qtdComprada,
  }) : super._() {
    assert(
      insumo.id != null,
      'Compra de insumo existente exige um insumo com id.',
    );
  }

  @override
  Map<String, dynamic> get referenciaDoInsumo => {'idInsumo': insumo.id};

  @override
  bool get conflitaPorDescricao => false;
}
