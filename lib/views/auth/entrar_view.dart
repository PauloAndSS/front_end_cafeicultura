import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/entrar_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'cadastro/cadastrar_dados_basicos_view.dart';

class EntrarView extends StatefulWidget {
  const EntrarView({super.key});

  @override
  State<EntrarView> createState() => _EntrarViewState();
}

class _EntrarViewState extends State<EntrarView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = EntrarViewmodel(service: ServicesAuth());
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);
      final propriedadesVM = Provider.of<PropriedadesUsuarioViewModel>(context, listen: false);

      final sucesso = await _viewModel.fazerLogin(
        _usuarioController.text,
        _senhaController.text,
        session,
        propriedadesVM,
      );

      if (sucesso && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.mensagemErro ?? 'Erro ao fazer login.'),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoCircular(size: 140),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: "E-mail, CPF ou CNPJ",
                          controller: _usuarioController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'O preenchimento é obrigatório';
                            }

                            final textoDigitado = value.trim();

                            if (textoDigitado.contains('@') ||
                                RegExp(r'[a-zA-Z]').hasMatch(textoDigitado)) {
                              return Validator.validarEmail(textoDigitado);
                            }

                            final apenasNumeros = textoDigitado.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );

                            if (apenasNumeros.length <= 11) {
                              return Validator.validarCPF(textoDigitado);
                            } else {
                              return Validator.validarCNPJ(textoDigitado);
                            }
                          },
                          hintText: "Digite seu E-mail, CPF ou CNPJ",
                        ),

                        const SizedBox(height: 20),

                        CustomTextField(
                          label: "Senha",
                          controller: _senhaController,
                          isPassword: true,
                          validator: Validator.validarSenha,
                          hintText: "Digite sua senha",
                        ),

                        const SizedBox(height: 24),

                        CustomButton(text: "Entrar", onPressed: _entrar),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextButton(
                              text: 'Esqueceu a senha?',
                              alignment: Alignment.centerLeft,
                              textColor: Colors.black87,
                              isBold: false,
                              isUnderlined: true,
                              onPressed:
                                  _entrar, // mudar ao implementar esqueci a senha
                            ),
                            CustomTextButton(
                              text: 'Criar conta',
                              alignment: Alignment.centerRight,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CadastrarView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
