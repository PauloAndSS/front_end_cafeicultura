import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/entrar_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import '../proprietario/cadastrar_dados_basicos_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_tema.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_formulario.dart';

class EntrarView extends StatefulWidget {
  const EntrarView({super.key});

  @override
  State<EntrarView> createState() => _EntrarViewState();
}

class _EntrarViewState extends State<EntrarView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = EntrarViewModel(service: ServicesAuth());
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _avisarRecuperacaoIndisponivel() {
    mostrarInfo(
      context,
      'A recuperação de senha ainda não está disponível neste aplicativo.',
    );
  }

  Future<void> _entrar() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);

      final sucesso = await _viewModel.fazerLogin(
        _usuarioController.text,
        _senhaController.text,
        session,
      );

      if (sucesso && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao fazer login.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTema.barraDeStatusSobreClaro,
      child: Scaffold(
        backgroundColor: AppCores.fundoAuth,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoCircular(size: 140),

                  const SizedBox(height: 32),

                  CartaoFormulario(
                    filho: Form(
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
                            validator: Validator.validarSenhaLogin,
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
                                textColor: AppCores.textoPrimario,
                                isBold: false,
                                isUnderlined: true,
                                onPressed: _avisarRecuperacaoIndisponivel,
                              ),
                              CustomTextButton(
                                text: 'Criar conta',
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CadastrarUsuarioView(),
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
      ),
    );
  }
}
