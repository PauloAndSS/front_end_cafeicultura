import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/proprietario/cadastrar_endereco_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/cadastrar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';

class CadastrarEnderecoView extends StatefulWidget {
  final Proprietario proprietario;

  const CadastrarEnderecoView({super.key, required this.proprietario});

  @override
  State<CadastrarEnderecoView> createState() => CadastrarEnderecoViewState();
}

class CadastrarEnderecoViewState extends State<CadastrarEnderecoView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CadastrarEnderecoViewModel();
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
    if (_formKey.currentState!.validate()) {
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
        mostrarSucesso(context, 'Conta e endereço cadastrados com sucesso!');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CadastrarPropriedadeView(),
          ),
        );
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar endereço.');
      }
    }
  }

  void _finalizarCadastroSemEndereco() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: AppCores.verdeAuth,
        appBar: const AppBarPadrao(cor: Colors.transparent, elevacao: 0),
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
                      text: "Finalizar Cadastro",
                      onPressed: _finalizarCadastroComEndereco,
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: "Adicionar endereço depois",
                      onPressed: _finalizarCadastroSemEndereco,
                      backgroundColor: Colors.white,
                      foregroundColor: AppCores.verdePrimario,
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
