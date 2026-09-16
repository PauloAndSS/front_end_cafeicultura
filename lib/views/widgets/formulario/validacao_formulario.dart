import 'package:flutter/material.dart';

const _duracaoDaRevelacao = Duration(milliseconds: 300);

const _alinhamentoDaRevelacao = 0.15;

bool validarRevelandoCampoInvalido(GlobalKey<FormState> chaveDoFormulario) {
  final formulario = chaveDoFormulario.currentState;

  if (formulario == null) return false;
  if (formulario.validate()) return true;

  revelarCampo(_primeiroCampoComErro(formulario.context));

  return false;
}

Future<void> revelarCampo(BuildContext? contextoDoCampo) {
  if (contextoDoCampo == null || !contextoDoCampo.mounted) {
    return Future.value();
  }

  return Scrollable.ensureVisible(
    contextoDoCampo,
    alignment: _alinhamentoDaRevelacao,
    duration: _duracaoDaRevelacao,
    curve: Curves.easeOutCubic,
  );
}

BuildContext? _primeiroCampoComErro(BuildContext raiz) {
  BuildContext? encontrado;

  void visitar(Element elemento) {
    if (encontrado != null) return;

    if (elemento is StatefulElement) {
      final estado = elemento.state;

      if (estado is FormFieldState && estado.hasError) {
        encontrado = elemento;
        return;
      }
    }

    elemento.visitChildren(visitar);
  }

  raiz.visitChildElements(visitar);

  return encontrado;
}
