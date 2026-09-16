import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';

IconData iconeDaAtividade(EventoAgricola atividade) => switch (atividade) {
      TratoCultural() => TipoAtividade.tratosCulturais.icone,
      _ => Icons.event_note,
    };
