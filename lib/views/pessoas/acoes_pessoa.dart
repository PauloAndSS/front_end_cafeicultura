import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_pessoa_view.dart';

Future<bool> cadastrarPessoaDoPapel(
  BuildContext context,
  CarregarPessoasMixin catalogoDePessoas,
  TipoPapel papel,
) async {
  final cadastrou = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => CadastrarPessoaView(papel: papel)),
  );

  if (cadastrou != true) return false;

  await catalogoDePessoas.carregarCategoria(papel, recarregar: true);

  return true;
}
