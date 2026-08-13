import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);
const _vermelhoErro = Color(0xFFD32F2F);

/// A "telinha" de cadastro de insumo.
///
/// É um diálogo, e não uma rota empilhada, para o formulário que está por baixo
/// (o cadastro do trato, com talhão, datas e descrição já preenchidos) continuar
/// vivo: nada é reconstruído, então nenhum dado se perde ao voltar.
///
/// Devolve o [Insumo] criado — já com id — ou `null` se o usuário cancelar.
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
      // O diálogo continua aberto com o que já foi digitado.
      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.mensagemErroInsumos ?? 'Erro ao cadastrar insumo.',
          ),
          backgroundColor: _vermelhoErro,
        ),
      );
      return;
    }

    Navigator.of(context).pop(criado);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Novo Insumo',
        style: TextStyle(color: _verdePrimario, fontWeight: FontWeight.bold),
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
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty ? 'Obrigatório' : null,
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
                  borderSide: const BorderSide(color: _cinzaBorda),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _cinzaBorda),
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
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _salvando ? null : _salvar,
          child: Text(
            _salvando ? 'Salvando...' : 'Cadastrar',
            style: const TextStyle(
              color: _verdePrimario,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
