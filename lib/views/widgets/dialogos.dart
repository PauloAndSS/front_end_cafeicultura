import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

Future<bool> confirmarAcao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String rotuloConfirmar,
  String rotuloCancelar = 'Cancelar',
  Color corConfirmar = AppCores.erro,
  Widget? complemento,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(titulo),
      content: complemento == null
          ? Text(mensagem)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mensagem),
                const SizedBox(height: 16),
                complemento,
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            rotuloCancelar,
            style: const TextStyle(color: AppCores.textoSecundario),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            rotuloConfirmar,
            style: TextStyle(color: corConfirmar, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  return confirmou ?? false;
}
Future<bool> confirmarDescarte(
  BuildContext context, {
  String titulo = 'Descartar alterações?',
  String mensagem =
      'Você preencheu alguns dados. Se sair agora, tudo será perdido.',
}) {
  return confirmarAcao(
    context,
    titulo: titulo,
    mensagem: mensagem,
    rotuloCancelar: 'Continuar editando',
    rotuloConfirmar: 'Descartar',
  );
}

List<Widget> acoesDeDialogo({
  required BuildContext context,
  required String rotuloConfirmar,
  required VoidCallback? aoConfirmar,
  VoidCallback? aoCancelar,
  bool? cancelarHabilitado,
  String rotuloCancelar = 'Cancelar',
  Color corConfirmar = AppCores.acao,
}) {
  final podeCancelar = cancelarHabilitado ?? (aoConfirmar != null);

  return [
    TextButton(
      onPressed: podeCancelar
          ? (aoCancelar ?? () => Navigator.of(context).pop())
          : null,
      child: Text(
        rotuloCancelar,
        style: const TextStyle(color: AppCores.textoSecundario),
      ),
    ),
    TextButton(
      onPressed: aoConfirmar,
      child: Text(
        rotuloConfirmar,
        style: TextStyle(color: corConfirmar, fontWeight: FontWeight.bold),
      ),
    ),
  ];
}
