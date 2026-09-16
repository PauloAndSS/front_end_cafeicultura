import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/validacao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/proprietario/cadastrar_endereco_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_formulario.dart';

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
    if (validarRevelandoCampoInvalido(_formKey)) {
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
        mostrarSucesso(context, 'Endereço cadastrado com sucesso!');
        _voltarParaOInicio();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar endereço.');
      }
    }
  }

  void _finalizarCadastroSemEndereco() {
    _voltarParaOInicio();
  }

  void _voltarParaOInicio() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
        backgroundColor: AppCores.fundoAuth,
        appBar: const AppBarPadrao(cor: AppCores.fundoAuth, elevacao: 0),
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
    return CartaoFormulario(
      filho: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Endereço',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.acao,
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
                    child: CircularProgressIndicator(),
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
                      backgroundColor: AppCores.superficie,
                      foregroundColor: AppCores.acao,
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
