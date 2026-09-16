import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';

const _anosDeAgendamento = 5;

DateTime get limiteAgendamento {
  final referencia = hoje();
  return DateTime(referencia.year + _anosDeAgendamento, 12, 31);
}

Future<DateTime?> selecionarData({
  required BuildContext context,
  required String ajuda,
  DateTime? inicial,
  DateTime? minima,
  DateTime? maxima,
  bool Function(DateTime dia)? diaSelecionavel,
}) {
  final primeira = apenasData(minima ?? DateTime(2000));

  final teto = apenasData(maxima ?? hoje());
  final ultima = teto.isBefore(primeira) ? primeira : teto;

  var inicialValida = apenasData(inicial ?? hoje());
  if (inicialValida.isBefore(primeira)) inicialValida = primeira;
  if (inicialValida.isAfter(ultima)) inicialValida = ultima;

  if (diaSelecionavel != null && !diaSelecionavel(inicialValida)) {
    final alternativa = _primeiroDiaAceito(
      apartirDe: inicialValida,
      ultima: ultima,
      aceita: diaSelecionavel,
    );

    if (alternativa == null) return Future.value(null);

    inicialValida = alternativa;
  }

  return showDatePicker(
    context: context,
    initialDate: inicialValida,
    firstDate: primeira,
    lastDate: ultima,
    helpText: ajuda,
    selectableDayPredicate: diaSelecionavel,
  );
}

DateTime? _primeiroDiaAceito({
  required DateTime apartirDe,
  required DateTime ultima,
  required bool Function(DateTime dia) aceita,
}) {
  var dia = apenasData(apartirDe);
  final limite = apenasData(ultima);

  while (!dia.isAfter(limite)) {
    if (aceita(dia)) return dia;
    dia = diaSeguinte(dia);
  }

  return null;
}
