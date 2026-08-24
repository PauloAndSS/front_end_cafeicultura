import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';

class EventoAgricolaFactory {
  EventoAgricolaFactory._();

  static EventoAgricola fromJson(Map<String, dynamic> json) {
    final modulo = json['modulo']?.toString() ?? '';
    final dadosBrutos = json['dados'];

    final dados = dadosBrutos is Map
        ? Map<String, dynamic>.from(dadosBrutos)
        : json;

    return switch (ModuloEvento.deCodigo(modulo)) {
      ModuloEvento.tratoCultural => TratoCultural.fromJson(dados),
      null => EventoAgricola.fromJson(dados, modulo: modulo),
    };
  }
}
