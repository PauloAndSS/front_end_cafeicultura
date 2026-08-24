import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

class BotaoExcluir extends StatelessWidget {
  final String titulo;

  final String mensagem;

  final Future<void> Function()? aoConfirmar;

  final String rotulo;

  final bool bloqueado;

  const BotaoExcluir({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.aoConfirmar,
    this.rotulo = 'Excluir',
    this.bloqueado = false,
  });

  Future<void> _confirmar(BuildContext context) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: titulo,
      mensagem: mensagem,
      rotuloConfirmar: rotulo,
    );

    if (!confirmou) return;

    await aoConfirmar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final desabilitado = bloqueado || aoConfirmar == null;

    final cor = desabilitado ? Colors.black38 : AppCores.erro;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: desabilitado ? null : () => _confirmar(context),
          icon: Icon(Icons.delete_outline, color: cor),
          label: Text(rotulo, style: TextStyle(color: cor, fontSize: 16)),
        ),
      ],
    );
  }
}
