import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/cadastrar_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/registrar_compra_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:provider/provider.dart';

class _ContextoDeCompra {
  final int idPropriedade;
  final List<Pessoa> fornecedores;

  const _ContextoDeCompra({
    required this.idPropriedade,
    required this.fornecedores,
  });
}

Future<Insumo?> abrirCadastroDeInsumo(
  BuildContext context,
  InsumosViewModel viewModel,
) async {
  final dados = await _reunirContexto(context, viewModel);

  if (dados == null || !context.mounted) return null;

  return mostrarCadastroInsumo(
    context: context,
    viewModel: viewModel,
    catalogoDePessoas: viewModel,
    idPropriedade: dados.idPropriedade,
    fornecedores: dados.fornecedores,
  );
}

Future<Insumo?> abrirRegistroDeCompra(
  BuildContext context,
  InsumosViewModel viewModel,
  Insumo insumo,
) async {
  final dados = await _reunirContexto(context, viewModel);

  if (dados == null || !context.mounted) return null;

  return mostrarRegistroDeCompra(
    context: context,
    viewModel: viewModel,
    insumo: insumo,
    idPropriedade: dados.idPropriedade,
    fornecedores: dados.fornecedores,
  );
}

Future<_ContextoDeCompra?> _reunirContexto(
  BuildContext context,
  InsumosViewModel viewModel,
) async {
  final idPropriedade =
      context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

  if (idPropriedade == null) {
    mostrarAviso(
      context,
      'Selecione uma propriedade antes de movimentar o armazém.',
    );
    return null;
  }

  final fornecedores = await viewModel.carregarFornecedores();

  if (!context.mounted) return null;

  return _ContextoDeCompra(
    idPropriedade: idPropriedade,
    fornecedores: fornecedores,
  );
}
