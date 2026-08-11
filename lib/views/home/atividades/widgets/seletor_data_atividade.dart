import 'package:flutter/material.dart';

const _verdePrimario = Color(0xFF67835C);

/// Calendário das telas de atividade, com o tema verde do app.
///
/// Só a abertura do picker foi extraída, e não um widget de par de campos: o
/// par início/término tem um consumidor só (o formulário genérico), enquanto
/// este `showDatePicker` aparece no cadastro, na finalização e no detalhe do
/// talhão.
///
/// [minima] limita para trás (a data de término não pode anteceder o início) e
/// o teto é sempre hoje: nenhuma atividade é lançada no futuro.
Future<DateTime?> selecionarDataAtividade({
  required BuildContext context,
  required String ajuda,
  DateTime? inicial,
  DateTime? minima,
}) {
  final hoje = DateTime.now();
  final primeira = minima ?? DateTime(2000);

  // Um `initialDate` fora do intervalo estoura assert no picker.
  var inicialValida = inicial ?? hoje;
  if (inicialValida.isBefore(primeira)) inicialValida = primeira;
  if (inicialValida.isAfter(hoje)) inicialValida = hoje;

  return showDatePicker(
    context: context,
    initialDate: inicialValida,
    firstDate: primeira,
    lastDate: hoje,
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
