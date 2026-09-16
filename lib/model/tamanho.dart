import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

enum Medida {
  hectare('hectare', 'Hectares'),
  m2('m2', 'm²');

  final String jsonValue;
  final String nomeExibicao;

  const Medida(this.jsonValue, this.nomeExibicao);

  factory Medida.fromString(String valor) {
    return Medida.values.firstWhere(
      (e) => e.jsonValue == valor.toLowerCase(),
      orElse: () => Medida.hectare,
    );
  }
}

class Tamanho {
  final double valor;
  final Medida medida;

  String get formatado => '${formatarDecimal(valor)} ${medida.nomeExibicao}';

  Tamanho({
    required this.valor,
    required this.medida,
  });

  factory Tamanho.fromJson(Map<String, dynamic> json) {
    return Tamanho(
      valor: (json['valor'] as num).toDouble(),
      medida: Medida.fromString(json['medida'] ?? 'hectare'), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valor': valor,
      'medida': medida.jsonValue,
    };
  }
}