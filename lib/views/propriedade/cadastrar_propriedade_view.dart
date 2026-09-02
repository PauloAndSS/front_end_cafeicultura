import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/cadastrar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';

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

  bool get _houveAlteracoes {
    return _nomeController.text.isNotEmpty ||
        _tamanhoValorController.text.isNotEmpty ||
        _cepController.text.isNotEmpty ||
        _logradouroController.text.isNotEmpty ||
        _bairroController.text.isNotEmpty ||
        _cidadeController.text.isNotEmpty ||
        _ufSelecionada != null;
  }

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
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);

      final resultado = await _viewModel.cadastrarPropriedade(
        session: session,
        nome: _nomeController.text,
        valorTamanho: AppMasks.paraDouble(_tamanhoValorController.text) ?? 0.0,
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

        mostrarSucesso(context, 'Propriedade cadastrada com sucesso!');
        Navigator.of(context).pop();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar propriedade.');
      }
    }
  }

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      mensagem:
          'Se você sair agora, todos os dados preenchidos serão perdidos.',
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (!_houveAlteracoes) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        final querSair = await _mostrarDialogoConfirmacao();

        if (querSair == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppCores.verdeAuth,
        appBar: const AppBarPadrao(
          tituloWidget: Text(
            'Nova Propriedade',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          cor: Colors.transparent,
          elevacao: 0,
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
                color: AppCores.verdePrimario,
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
                    inputFormatters: [AppMasks.decimal],
                    hintText: 'Ex: 15,5',
                    validator: Validator.obrigatorio,
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
                        initialValue: _tamanhoMedida,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppCores.verdePrimario,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppCores.borda,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppCores.borda,
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
              child: Divider(height: 1, thickness: 1, color: AppCores.borda),
            ),

            const Text(
              'Endereço da Propriedade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
            const SizedBox(height: 16),

            BlocoEndereco(
              controllerCep: _cepController,
              controllerLogradouro: _logradouroController,
              controllerBairro: _bairroController,
              controllerCidade: _cidadeController,
              uf: _ufSelecionada,
              aoSelecionarUf: (novo) => setState(() => _ufSelecionada = novo),
              dicaLogradouro: 'Rodovia, estrada, número, etc.',
              dicaBairro: 'Digite o bairro ou localidade',
            ),

            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppCores.verdePrimario),
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
