import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_tema.dart';

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  final String? titulo;

  final Widget? tituloWidget;

  final Color? cor;
  final Color? corConteudo;
  final double? elevacao;
  final Widget? leading;
  final List<Widget>? acoes;

  const AppBarPadrao({
    super.key,
    this.titulo,
    this.tituloWidget,
    this.cor,
    this.corConteudo,
    this.elevacao,
    this.leading,
    this.acoes,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Brightness? get _brilhoDoFundo {
    final fundo = cor;

    if (fundo == null) return null;

    final efetiva = fundo.a == 0 ? AppCores.fundo : fundo;

    if (efetiva == AppCores.casca) return null;

    return ThemeData.estimateBrightnessForColor(efetiva);
  }

  @override
  Widget build(BuildContext context) {
    final brilho = _brilhoDoFundo;
    final sobreClaro = brilho == Brightness.light;
    final corDoConteudo =
        corConteudo ?? (sobreClaro ? AppCores.textoPrimario : null);

    return AppBar(
      title: tituloWidget ?? (titulo == null ? null : Text(titulo!)),
      backgroundColor: cor,
      foregroundColor: corDoConteudo,
      titleTextStyle: corDoConteudo == null
          ? null
          : Theme.of(
              context,
            ).appBarTheme.titleTextStyle?.copyWith(color: corDoConteudo),
      elevation: elevacao ?? (cor == null ? null : 0),
      leading: leading,
      actions: acoes,
      systemOverlayStyle: brilho == null
          ? null
          : (sobreClaro
                ? AppTema.barraDeStatusSobreClaro
                : AppTema.barraDeStatusSobreEscuro),
    );
  }
}
