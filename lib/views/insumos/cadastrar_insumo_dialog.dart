import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

Future<Insumo?> mostrarCadastroInsumo({
  required BuildContext context,
  required CarregarInsumosMixin viewModel,
  required int idProprietario,
}) {
  return showDialog<Insumo>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CadastrarInsumoDialog(
      viewModel: viewModel,
      idProprietario: idProprietario,
    ),
  );
}

class _CadastrarInsumoDialog extends StatefulWidget {
  final CarregarInsumosMixin viewModel;
  final int idProprietario;

  const _CadastrarInsumoDialog({
    required this.viewModel,
    required this.idProprietario,
  });

  @override
  State<_CadastrarInsumoDialog> createState() => _CadastrarInsumoDialogState();
}

class _CadastrarInsumoDialogState extends State<_CadastrarInsumoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  MedidaInsumo? _medidaSelecionada;
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final criado = await widget.viewModel.cadastrarInsumo(
      idProprietario: widget.idProprietario,
      descricao: _descricaoController.text,
      medida: _medidaSelecionada!,
    );

    if (!mounted) return;

    if (criado == null) {
      setState(() => _salvando = false);

      mostrarErro(context, widget.viewModel.mensagemErroInsumos ?? 'Erro ao cadastrar insumo.');
      return;
    }

    Navigator.of(context).pop(criado);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Novo Insumo',
        style: TextStyle(color: AppCores.verdePrimario, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Descrição',
              controller: _descricaoController,
              hintText: 'Ex: Ureia Agrícola 46% N',
              validator: Validator.obrigatorio,
            ),
            const Text(
              'Unidade de medida',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MedidaInsumo>(
              initialValue: _medidaSelecionada,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppCores.borda),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppCores.borda),
                ),
              ),
              hint: const Text(
                'Selecione a medida',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              items: MedidaInsumo.values.map((medida) {
                return DropdownMenuItem(
                  value: medida,
                  child: Text(medida.rotulo, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: _salvando
                  ? null
                  : (valor) => setState(() => _medidaSelecionada = valor),
              validator: (valor) => valor == null ? 'Obrigatório' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: _salvando ? 'Salvando...' : 'Cadastrar',
        aoConfirmar: _salvando ? null : _salvar,
      ),
    );
  }
}
