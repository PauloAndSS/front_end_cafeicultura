import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/cadastrar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';
import 'package:provider/provider.dart';

class CadastrarPropriedadeView extends StatefulWidget {
  const CadastrarPropriedadeView({super.key});

  @override
  State<CadastrarPropriedadeView> createState() =>
      _CadastrarPropriedadeViewState();
}

class _CadastrarPropriedadeViewState extends State<CadastrarPropriedadeView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CadastrarPropriedadeViewModel();

  final _nomeController = TextEditingController();
  final _tamanhoValorController = TextEditingController();
  Medida _tamanhoMedida = Medida.hectare;

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  UF? _ufSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _tamanhoValorController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _salvarPropriedade() async {
    if (_formKey.currentState!.validate() && _ufSelecionada != null) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);

      final resultado = await _viewModel.cadastrarPropriedade(
        session: session,
        nome: _nomeController.text,
        valorTamanho:
            double.tryParse(
              _tamanhoValorController.text.replaceAll(',', '.'),
            ) ??
            0.0,
        medidaTamanho: _tamanhoMedida.jsonValue,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufSelecionada!,
        pais: 'Brasil',
      );

      if (resultado == true && mounted) {
        Provider.of<PropriedadesUsuarioViewModel>(context, listen: false)
            .carregarPropriedades();
 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propriedade cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar propriedade.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_ufSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o Estado (UF).'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _mostrarDialogoConfirmacao() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
            'Se você sair agora, todos os dados preenchidos serão perdidos.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true),
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final querSair = await _mostrarDialogoConfirmacao();

        if (querSair == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF9FB896),
        appBar: AppBar(
          title: const Text(
            'Nova Propriedade',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  const LogoCircular(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados da Propriedade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF67835C),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Nome da Propriedade',
              controller: _nomeController,
              validator: Validator.validarNome,
              hintText: 'Ex: Sítio Vô Augusto',
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Tamanho',
                    controller: _tamanhoValorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [AppMasks.inteiroMilhar],
                    hintText: 'Ex: 15.5',
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medida',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Medida>(
                        value: _tamanhoMedida,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF67835C),
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                        items: Medida.values.map((medida) {
                          return DropdownMenuItem<Medida>(
                            value: medida,
                            child: Text(
                              medida.nomeExibicao,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (Medida? val) {
                          if (val != null) {
                            setState(() => _tamanhoMedida = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            ),

            const Text(
              'Endereço da Propriedade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF67835C),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'CEP',
              controller: _cepController,
              keyboardType: TextInputType.number,
              validator: Validator.validarCEP,
              inputFormatters: [AppMasks.cep],
              hintText: 'Digite o CEP (apenas números)',
            ),

            CustomTextField(
              label: 'Logradouro',
              controller: _logradouroController,
              validator: Validator.validarNome,
              hintText: 'Rodovia, estrada, número, etc.',
            ),

            CustomTextField(
              label: 'Bairro',
              controller: _bairroController,
              validator: Validator.validarNome,
              hintText: 'Digite o bairro ou localidade',
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Cidade',
                    controller: _cidadeController,
                    validator: Validator.validarNome,
                    hintText: 'Nome da cidade',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: UfDropdown(
                    value: _ufSelecionada,
                    onChanged: (UF? newValue) {
                      setState(() {
                        _ufSelecionada = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF67835C)),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      text: "Salvar Propriedade",
                      onPressed: _salvarPropriedade,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
