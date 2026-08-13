import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_em_desenvolvimento.dart';

/// Telas de listagem por tipo de atividade.
///
/// Esta tabela — e não um `bool` no enum — é o que define "implementado".
/// O que ela corrige: a versão anterior fazia
/// `if (tipo.implementado) return const TratoCulturalView();`, que devolveria a
/// tela de trato cultural para **qualquer** tipo marcado como implementado.
/// Funcionava só enquanto houvesse um tipo só.
///
/// Para ligar uma atividade nova, basta uma linha aqui.
const Map<TipoAtividade, WidgetBuilder> telasDeAtividade = {
  TipoAtividade.tratosCulturais: _construirTratoCultural,
};

Widget _construirTratoCultural(BuildContext context) =>
    const TratoCulturalView();

bool atividadeImplementada(TipoAtividade tipo) =>
    telasDeAtividade.containsKey(tipo);

/// Devolve a tela do [tipo], ou o placeholder se ele ainda não tiver uma.
Widget construirTelaAtividade(BuildContext context, TipoAtividade tipo) {
  final construtor = telasDeAtividade[tipo];

  if (construtor == null) return AtividadeEmDesenvolvimento(tipo: tipo);

  return construtor(context);
}
