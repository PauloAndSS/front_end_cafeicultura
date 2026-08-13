import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';

/// Ícone de uma atividade, escolhido pelo tipo concreto.
///
/// As abas de atividade passam o ícone fixo para o card, porque cada uma
/// mostra um tipo só. Onde a lista é heterogênea — o calendário da home, que
/// junta todos os módulos — o ícone tem de sair da própria atividade.
///
/// O `default` cobre [EventoGenerico]: um módulo que o app ainda não modela
/// aparece com ícone neutro em vez de sumir da lista.
IconData iconeDaAtividade(EventoAgricola atividade) => switch (atividade) {
      TratoCultural() => Icons.grass,
      _ => Icons.event_note,
    };
