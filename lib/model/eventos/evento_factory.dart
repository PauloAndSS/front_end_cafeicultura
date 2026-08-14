import 'package:frond_end_cafeicultura_mobile/model/eventos/evento_generico.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';

/// Desserialização das atividades vindas de `/eventos/propriedade/{id}`.
///
/// O backend embrulha cada item num envelope com o módulo de origem:
///
/// ```json
/// { "modulo": "TRATO_CULTURAL", "dados": { ... } }
/// ```
///
/// É o mesmo envelope do relatório de safra, que `SafraEvento` já desembrulha
/// por conta própria. Aqui a escolha foi outra: em vez de mais um model
/// achatado, o envelope vira o model concreto que a listagem de atividades já
/// usa — assim `AtividadeCard`, `corDoStatus` e a tela de detalhes funcionam
/// sem tradução no meio.
class EventoFactory {
  EventoFactory._();

  /// Aceita tanto o envelope quanto o DTO cru.
  ///
  /// Sem `modulo` no mapa, o item **é** o próprio `dados` — é assim que a
  /// listagem de tratos culturais, que não embrulha nada, passa pelo mesmo
  /// parser.
  static EventoAgricola fromJson(Map<String, dynamic> json) {
    final modulo = json['modulo']?.toString() ?? '';
    final dadosBrutos = json['dados'];

    final dados = dadosBrutos is Map
        ? Map<String, dynamic>.from(dadosBrutos)
        : json;

    return switch (modulo) {
      'TRATO_CULTURAL' => TratoCultural.fromJson(dados),
      _ => EventoGenerico.fromJson(dados, modulo: modulo),
    };
  }
}
