import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';

Future<void> abrirCadastroDeTalhao(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CadastrarTalhaoView()),
  );
}
