import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class MarcaOpcional extends StatelessWidget {
  const MarcaOpcional({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        '(Opcional)',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppCores.textoTerciario),
      ),
    );
  }
}

Widget rotuloDeCampo(
  BuildContext context,
  String texto, {
  bool opcional = false,
}) {
  final rotulo = Text(texto, style: Theme.of(context).textTheme.titleSmall);

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: opcional
        ? Row(children: [Flexible(child: rotulo), const MarcaOpcional()])
        : rotulo,
  );
}

Widget tituloDeSecaoFormulario(BuildContext context, String texto) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppCores.acao,
      ),
    ),
  );
}

TextStyle? estiloDeValorDeCampo(BuildContext context) {
  return Theme.of(context)
      .textTheme
      .bodyLarge
      ?.copyWith(color: AppCores.textoPrimario);
}

Widget dicaDeSeletor(BuildContext context, String texto) {
  return Text(
    texto,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppCores.textoTerciario,
    ),
  );
}
