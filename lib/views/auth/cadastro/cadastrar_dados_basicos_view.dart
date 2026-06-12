import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/cadastro/cadastrar_dados_basicos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/auth/cadastro/cadastrar_endereco_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart'; 
import '../entrar_view.dart';

class CadastrarView extends StatefulWidget {
  const CadastrarView({super.key});

  @override
  State<CadastrarView> createState() => _CadastrarViewState();
}

class _CadastrarViewState extends State<CadastrarView> {
  final _viewModel = CadastrarViewModel();
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

  void _cadastrarDadosBasicos() {
    if (_formKey.currentState!.validate()) {
      
      FocusScope.of(context).unfocus();

      final resultado = _viewModel.cadastroDadosBasicos(
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: _telefoneController.text,
        nome: _viewModel.tipoPessoaAtual == TipoPessoa.fisica ? _nomeController.text : null,
        cpf: _viewModel.tipoPessoaAtual == TipoPessoa.fisica ? _cpfController.text : null,
        razaoSocial: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _razaoSocialController.text : null,
        cnpj: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _cnpjController.text : null,
        inscEstadual: _viewModel.tipoPessoaAtual == TipoPessoa.juridica ? _inscricaoEstadualController.text : null,
      );

      if (resultado != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CadastrarEnderecoView(
              proprietario: resultado.proprietario,
              senha: resultado.senha,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ops! Verifique se os documentos informados são válidos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9FB896), 
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
            // Seletor de Tipo de Conta (PF ou PJ)
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
                      value: _viewModel.tipoPessoaAtual,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF67835C)), // Cor do tema
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
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
              builder: (context, _) {
                if (_viewModel.tipoPessoaAtual == TipoPessoa.fisica) {
                  return Column(
                    children: [
                      CustomTextField(
                        label: 'Nome Completo', 
                        controller: _nomeController,
                        validator: Validator.validarNome,
                        hintText: 'Digite seu nome completo',
                      ),
                      CustomTextField(
                        label: 'CPF', 
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        validator: Validator.validarCPF,
                        inputFormatters: [AppMasks.cpf],
                        hintText: '000.000.000-00',
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      CustomTextField(
                        label: 'Razão Social', 
                        controller: _razaoSocialController,
                        validator: Validator.validarRazaoSocial,
                        hintText: 'Digite sua razão social',
                      ),
                      CustomTextField(
                        label: 'CNPJ', 
                        controller: _cnpjController,
                        keyboardType: TextInputType.number,
                        validator: Validator.validarCNPJ,
                        inputFormatters: [AppMasks.cnpj],
                        hintText: '00.000.000/0000-00',
                      ),
                      CustomTextField(
                        label: 'Inscrição Estadual (Opcional)', 
                        controller: _inscricaoEstadualController,
                        keyboardType: TextInputType.number,
                        validator: Validator.validarInscEstadual,
                        hintText: 'Digite sua inscrição estadual (Opcional)',
                      ),
                    ],
                  );
                }
              },
            ),

            CustomTextField(
              label: 'E-mail', 
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validator.validarEmail,
              hintText: 'Digite seu e-mail',
            ),
            CustomTextField(
              label: 'Telefone', 
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              validator: Validator.validarTelefone,
              inputFormatters: [AppMasks.telefone],
              hintText: 'Digite seu telefone',
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
                  return const CircularProgressIndicator(color: Color(0xFF67835C));
                }
                return CustomButton(
                  text: "Continuar Cadastro",
                  onPressed: _cadastrarDadosBasicos,
                );
              },
            ),
            
            const SizedBox(height: 20),

            // Link para Login
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