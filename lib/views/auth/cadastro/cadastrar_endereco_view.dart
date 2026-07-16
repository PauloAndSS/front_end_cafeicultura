import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/cadastro/cadastrar_endereco_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';

class CadastrarEnderecoView extends StatefulWidget {
  final Proprietario proprietario;

  const CadastrarEnderecoView({super.key, required this.proprietario});

  @override
  State<CadastrarEnderecoView> createState() => CadastrarEnderecoViewState();
}

class CadastrarEnderecoViewState extends State<CadastrarEnderecoView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CadastrarEnderecoViewmodel();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  UF? _ufSelecionada;

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _finalizarCadastroComEndereco() async {
    if (_formKey.currentState!.validate() && _ufSelecionada != null) {
      FocusScope.of(context).unfocus();

      final proprietarioSalvo = await _viewModel.adicionarEndereco(
        proprietarioLogado: widget.proprietario,
        cepDigitado: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufSelecionada!,
      );

      if (proprietarioSalvo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta e endereço cadastrados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        ); // TODO: Ao implementar criaçao de propriedade, mudar destino da rota
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar endereço.',
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

  void _finalizarCadastroSemEndereco() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    ); // TODO: Ao implementar criaçao de propriedade, mudar destino da rota
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false, // Bloqueia o "voltar" padrão (que iria pra tela de cadastro)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Ao invés de voltar uma tela, mandamos ele para a tela inicial!
        // Isso tem o mesmo efeito do botão "Adicionar endereço depois"
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF9FB896),
        appBar: AppBar(
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
                  _buildEnderecoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnderecoCard() {
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
              'Seu Endereço',
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
              hintText: 'Rua, Avenida, número, complemento...',
            ),

            CustomTextField(
              label: 'Bairro',
              controller: _bairroController,
              validator: Validator.validarNome,
              hintText: 'Digite o bairro ou distrito',
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
                      text: "Finalizar Cadastro",
                      onPressed: _finalizarCadastroComEndereco,
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: "Adicionar endereço depois",
                      onPressed: _finalizarCadastroSemEndereco,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF67835C),
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
