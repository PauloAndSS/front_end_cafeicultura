import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class BotaoEncerrar extends StatelessWidget {
  final String rotulo;

  final String rotuloCarregando;

  final VoidCallback? aoTocar;

  final bool carregando;

  const BotaoEncerrar({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.rotuloCarregando = 'Encerrando...',
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final desabilitado = carregando || aoTocar == null;

    return OutlinedButton.icon(
      onPressed: desabilitado ? null : aoTocar,
      icon: const Icon(Icons.archive_outlined, size: 20),
      label: Text(carregando ? rotuloCarregando : rotulo),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppCores.avisoTexto,
        side: const BorderSide(color: AppCores.aviso),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
