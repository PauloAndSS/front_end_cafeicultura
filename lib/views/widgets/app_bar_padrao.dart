import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  final String? titulo;

  final Widget? tituloWidget;

  final Color cor;
  final Color? corConteudo;
  final double? elevacao;
  final Widget? leading;
  final List<Widget>? acoes;

  const AppBarPadrao({
    super.key,
    this.titulo,
    this.tituloWidget,
    this.cor = AppCores.verdePrimario,
    this.corConteudo = Colors.white,
    this.elevacao,
    this.leading,
    this.acoes,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: tituloWidget ?? (titulo == null ? null : Text(titulo!)),
      backgroundColor: cor,
      foregroundColor: corConteudo,
      elevation: elevacao,
      leading: leading,
      actions: acoes,
    );
  }
}
