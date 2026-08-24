import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/proprietario/cadastrar_dados_basicos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/proprietario/cadastrar_endereco_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import '../auth/entrar_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_identificacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_contato.dart';

class CadastrarUsuarioView extends StatefulWidget {
  const CadastrarUsuarioView({super.key});

  @override
  State<CadastrarUsuarioView> createState() => _CadastrarUsuarioViewState();
}

class _CadastrarUsuarioViewState extends State<CadastrarUsuarioView> {
  final _viewModel = CadastrarDadosBasicosViewModel();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();

  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _confirmarSenhaController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

void _cadastrarDadosBasicos() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);

      final resultado = await _viewModel.cadastrarDadosBasicos(
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: _telefoneController.text,
        nome: _viewModel.tipoPessoaAtual == TipoPessoa.fisica ? _nomeController.text : null,
        cpf: _viewModel.tipoPessoaAtual == TipoPessoa.fisica ? _cpfController.text : null,
        razaoSocial: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _razaoSocialController.text : null,
        cnpj: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _cnpjController.text : null,
        inscEstadual: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _inscricaoEstadualController.text : null,
        session: session,
      );

      if (resultado != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CadastrarEnderecoView(
              proprietario: resultado,
            ),
          ),
        );
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ?? 'Erro desconhecido.');
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.verdeAuth,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
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
          children: [
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TipoPessoa>(
                      initialValue: _viewModel.tipoPessoaAtual,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppCores.verdePrimario),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppCores.borda),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppCores.borda),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TipoPessoa.fisica,
                          child: Text('Pessoa Física (CPF)'),
                        ),
                        DropdownMenuItem(
                          value: TipoPessoa.juridica,
                          child: Text('Pessoa Jurídica (CNPJ)'),
                        ),
                      ],
                      onChanged: (TipoPessoa? valor) {
                        if (valor != null) {
                          _viewModel.alterarTipoPessoa(valor);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => BlocoIdentificacao(
                pessoaFisica: _viewModel.tipoPessoaAtual == TipoPessoa.fisica,
                controllerNome: _nomeController,
                controllerRazaoSocial: _razaoSocialController,
                controllerCpf: _cpfController,
                controllerCnpj: _cnpjController,
                controllerInscricaoEstadual: _inscricaoEstadualController,
                dicaNome: 'Digite seu nome completo',
                dicaRazaoSocial: 'Digite sua razão social',
              ),
            ),

            BlocoContato(
              controllerEmail: _emailController,
              controllerTelefone: _telefoneController,
              dicaEmail: 'Digite seu e-mail',
              dicaTelefone: 'Digite seu telefone',
            ),
            CustomTextField(
              label: 'Senha',
              controller: _senhaController,
              isPassword: true,
              validator: Validator.validarSenha,
              hintText: 'Digite sua senha',
            ),
            CustomTextField(
              label: 'Confirmar Senha',
              controller: _confirmarSenhaController,
              isPassword: true,
              validator: (value) => Validator.validarConfirmacaoSenha(value, _senhaController.text),
              hintText: 'Confirme sua senha',
            ),

            const SizedBox(height: 10),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const CircularProgressIndicator(color: AppCores.verdePrimario);
                }
                return CustomButton(
                  text: "Continuar Cadastro",
                  onPressed: _cadastrarDadosBasicos,
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Já tem uma conta? "),
                CustomTextButton(
                  text: "Entrar",
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const EntrarView()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
