import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';

/// Atividade de um módulo que o app ainda não modela.
///
/// A rota `/eventos/propriedade/{id}` devolve o que existir no backend, e o
/// backend ganha módulos antes do app. Sem esta classe, uma colheita voltando
/// da API cairia num `default` e sumiria do calendário — um dia com atividade
/// apareceria vazio, que é pior do que mostrar um título genérico.
///
/// Só carrega o que a base já sabe ler (datas, talhão, descrição,
/// responsáveis). O que for específico do módulo fica no JSON e é ignorado até
/// alguém escrever o model concreto.
class EventoGenerico extends EventoAgricola {
  /// O discriminador cru do backend: `TRATO_CULTURAL`, `COLHEITA`...
  final String modulo;

  EventoGenerico.fromJson(super.json, {required this.modulo})
      : super.fromJson();

  @override
  String get tituloExibicao => _nomeAmigavel(modulo);

  /// `TRATO_CULTURAL` → `Trato cultural`. Mesma regra de
  /// `SafraEvento._nomeAmigavelModulo`, aplicada a qualquer módulo em vez de
  /// um `switch` que precisaria de uma linha nova a cada release do backend.
  static String _nomeAmigavel(String modulo) {
    if (modulo.isEmpty) return 'Atividade';

    final palavras = modulo.toLowerCase().split('_').where((p) => p.isNotEmpty);

    if (palavras.isEmpty) return 'Atividade';

    final primeira = palavras.first;

    return [
      primeira[0].toUpperCase() + primeira.substring(1),
      ...palavras.skip(1),
    ].join(' ');
  }
}
