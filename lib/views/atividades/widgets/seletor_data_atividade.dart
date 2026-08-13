import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';

const _verdePrimario = Color(0xFF67835C);

/// Quanto para frente o calendário de agendamento vai. Não há regra de negócio
/// aqui — é só um teto para o `showDatePicker` não rolar indefinidamente.
const _anosDeAgendamento = 5;

/// Teto de quem agenda: a data de início aceita futuro.
DateTime get limiteAgendamento {
  final referencia = hoje();
  return DateTime(referencia.year + _anosDeAgendamento, 12, 31);
}

/// Calendário das telas de atividade, com o tema verde do app.
///
/// Só a abertura do picker foi extraída, e não um widget de par de campos: o
/// par início/término tem um consumidor só (o formulário genérico), enquanto
/// este `showDatePicker` aparece no cadastro, na confirmação e no detalhe do
/// talhão.
///
/// [minima] limita para trás (a data de término não pode anteceder o início) e
/// [maxima] para frente. O teto **padrão** é hoje, porque é o caso da maioria
/// das chamadas — só a data de início passa [limiteAgendamento] para permitir
/// agendamento.
Future<DateTime?> selecionarDataAtividade({
  required BuildContext context,
  required String ajuda,
  DateTime? inicial,
  DateTime? minima,
  DateTime? maxima,
}) {
  final primeira = minima ?? DateTime(2000);
  final ultima = maxima ?? hoje();

  // Um `initialDate` fora do intervalo estoura assert no picker.
  var inicialValida = inicial ?? hoje();
  if (inicialValida.isBefore(primeira)) inicialValida = primeira;
  if (inicialValida.isAfter(ultima)) inicialValida = ultima;

  return showDatePicker(
    context: context,
    initialDate: inicialValida,
    firstDate: primeira,
    lastDate: ultima,
    helpText: ajuda,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _verdePrimario,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );
}
