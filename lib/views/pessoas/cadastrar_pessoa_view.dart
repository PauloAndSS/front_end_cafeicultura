import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/cadastrar_pessoa_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_identificacao.dart';

class CadastrarPessoaView extends StatefulWidget {
  final TipoPapel papel;

  const CadastrarPessoaView({super.key, required this.papel});

  @override
  State<CadastrarPessoaView> createState() => _CadastrarPessoaViewState();
}

class _CadastrarPessoaViewState extends State<CadastrarPessoaView> {
  late final _viewModel = CadastrarPessoaViewModel(widget.papel);
  final _formKey = GlobalKey<FormState>();

  bool _isPessoaFisica = true;

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  final _salarioController = TextEditingController();
  final _ctpsController = TextEditingController();

  TipoPapel get _papel => widget.papel;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _inscricaoEstadualController.dispose();
    _salarioController.dispose();
    _ctpsController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  bool _temDadosAlterados() {
    return _nomeController.text.isNotEmpty ||
        _cpfController.text.isNotEmpty ||
        _razaoSocialController.text.isNotEmpty ||
        _cnpjController.text.isNotEmpty ||
        _inscricaoEstadualController.text.isNotEmpty ||
        _salarioController.text.isNotEmpty ||
        _ctpsController.text.isNotEmpty;
  }

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      mensagem:
          'Você preencheu alguns dados. Se sair agora, tudo será perdido. Deseja realmente sair?',
    );
  }

  Pessoa _montarPessoa() {
    if (_isPessoaFisica) {
      return PessoaFisica(
        nome: _nomeController.text.trim(),
        cpf: CPF.criar(_cpfController.text),
      );
    }

    return PessoaJuridica(
      razaoSocial: _razaoSocialController.text.trim(),
      cnpj: CNPJ.criar(_cnpjController.text),
      inscricaoEstadual: _inscricaoEstadualController.text.isNotEmpty
          ? _inscricaoEstadualController.text.trim()
          : null,
    );
  }

  PapelPessoa _montarPapel(Pessoa pessoa) {
    return switch (_papel) {
      TipoPapel.funcionario => Funcionario(
          pessoa: pessoa,
          salario: double.tryParse(
            _salarioController.text.replaceAll('.', '').replaceAll(',', '.'),
          ),
          ctps: _ctpsController.text.isNotEmpty
              ? _ctpsController.text.trim()
              : null,
        ),
      TipoPapel.meeiro => Meeiro(pessoa: pessoa),
      TipoPapel.fornecedor => Fornecedor(pessoa: pessoa),
      TipoPapel.prestador => PrestadorDeServico(pessoa: pessoa),
      TipoPapel.cliente => Cliente(pessoa: pessoa),
    };
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final sucesso = await _viewModel.cadastrarPessoa(
      _montarPapel(_montarPessoa()),
    );

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, '${_papel.titulo} cadastrado com sucesso!');
      Navigator.pop(context, true);
    } else if (_viewModel.mensagemErro != null) {
      mostrarErro(context, _viewModel.mensagemErro!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        if (!_temDadosAlterados()) {
          Navigator.pop(context);
          return;
        }

        final confirmarSaida = await _mostrarDialogoConfirmacao();

        if (confirmarSaida && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(
          titulo: 'Cadastrar ${_papel.titulo}',
          cor: AppCores.verdeAuth,
          corConteudo: null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_papel.aceitaPessoaJuridica) ...[
                      rotuloDeCampo('Tipo de Cadastro'),
                      DropdownButtonFormField<bool>(
                        initialValue: _isPessoaFisica,
                        decoration: decoracaoDeSeletor(),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Pessoa Física (CPF)'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Pessoa Jurídica (CNPJ)'),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _isPessoaFisica = valor);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    BlocoIdentificacao(
                      pessoaFisica: _isPessoaFisica,
                      controllerNome: _nomeController,
                      controllerRazaoSocial: _razaoSocialController,
                      controllerCpf: _cpfController,
                      controllerCnpj: _cnpjController,
                      controllerInscricaoEstadual: _inscricaoEstadualController,
                    ),

                    if (_papel == TipoPapel.funcionario) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Dados do Funcionário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 32),

                      CustomTextField(
                        label: 'CTPS (Opcional)',
                        controller: _ctpsController,
                        hintText: 'Número da carteira de trabalho',
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        label: 'Salário Base (R\$) (Opcional)',
                        controller: _salarioController,
                        hintText: '0.00',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [AppMasks.decimal],
                      ),
                    ],

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCores.verdeSecundario,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _viewModel.isLoading ? null : _salvar,
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Salvar ${_papel.titulo}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
