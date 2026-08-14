import 'package:intl/intl.dart';

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

final _numeroBr = NumberFormat.decimalPattern('pt_BR');

class Tamanho {
  final double valor;
  final Medida medida;

  /// "12 Hectares", "1.250,5 m²".
  ///
  /// Existe porque as telas montavam `'$valor ${medida.name}'`, que imprime o
  /// `double` cru e o nome do enum — "10.0 hectare" em vez de "10 Hectares".
  /// Formatação de model mora no model.
  String get formatado => '${_numeroBr.format(valor)} ${medida.nomeExibicao}';

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