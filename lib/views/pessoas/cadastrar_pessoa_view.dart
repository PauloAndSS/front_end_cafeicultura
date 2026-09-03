import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/cadastrar_pessoa_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_identificacao.dart';

class CadastrarPessoaView extends StatefulWidget {
  const CadastrarPessoaView({super.key});

  @override
  State<CadastrarPessoaView> createState() => _CadastrarPessoaViewState();
}

class _CadastrarPessoaViewState extends State<CadastrarPessoaView> {
  final _viewModel = CadastrarPessoaViewModel();
  final _formKey = GlobalKey<FormState>();

  bool _isPessoaFisica = true;

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  final _salarioController = TextEditingController();
  final _ctpsController = TextEditingController();

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
        _ctpsController.text.isNotEmpty ||
        _viewModel.papelSelecionado != null;
  }

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      mensagem:
          'Você preencheu alguns dados. Se sair agora, tudo será perdido. Deseja realmente sair?',
    );
  }
  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final pessoaBase = _isPessoaFisica
          ? PessoaFisica(
              nome: _nomeController.text.trim(),
              cpf: CPF.criar(_cpfController.text),
            )
          : PessoaJuridica(
              razaoSocial: _razaoSocialController.text.trim(),
              cnpj: CNPJ.criar(_cnpjController.text),
              inscricaoEstadual: _inscricaoEstadualController.text.isNotEmpty
                  ? _inscricaoEstadualController.text.trim()
                  : null,
            );

      final mapConstrutores = {
        TipoPapel.funcionario: (p) {
          final salarioTratado = _salarioController.text.replaceAll('.', '').replaceAll(',', '.');
          return Funcionario(
            pessoa: p,
            salario: double.tryParse(salarioTratado),
            ctps: _ctpsController.text.isNotEmpty ? _ctpsController.text.trim() : null,
          );
        },
        TipoPapel.meeiro: (p) => Meeiro(pessoa: p),
        TipoPapel.fornecedor: (p) => Fornecedor(pessoa: p),
        TipoPapel.prestador: (p) => PrestadorDeServico(pessoa: p),
        TipoPapel.cliente: (p) => Cliente(pessoa: p),
      };

      final objetoPapel = mapConstrutores[_viewModel.papelSelecionado!]!(pessoaBase);

      final sucesso = await _viewModel.cadastrarPessoa(
        objetoPapel: objetoPapel,
      );

      if (sucesso && mounted) {
        mostrarSucesso(context, 'Pessoa cadastrada com sucesso!');
        Navigator.pop(context, true);
      } else if (mounted && _viewModel.mensagemErro != null) {
        mostrarErro(context, _viewModel.mensagemErro!);
      }
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
        appBar: const AppBarPadrao(
          titulo: 'Cadastrar Pessoa',
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
                builder: (context, _) {

                  final bool forcarPessoaFisica =
                      _viewModel.papelSelecionado == TipoPapel.funcionario ||
                      _viewModel.papelSelecionado == TipoPapel.meeiro;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Papel da Pessoa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TipoPapel>(
                        initialValue: _viewModel.papelSelecionado,
                        hint: const Text('Selecione o papel'),
                        validator: Validator.selecaoObrigatoria,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TipoPapel.funcionario,
                            child: Text('Funcionário'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapel.meeiro,
                            child: Text('Meeiro'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapel.fornecedor,
                            child: Text('Fornecedor'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapel.prestador,
                            child: Text('Prestador de Serviço'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapel.cliente,
                            child: Text('Cliente'),
                          ),
                        ],
                        onChanged: (papel) {
                          _viewModel.selecionarPapel(papel);

                          if (papel == TipoPapel.funcionario || papel == TipoPapel.meeiro) {
                            setState(() => _isPessoaFisica = true);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Tipo de Cadastro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<bool>(
                        value: _isPessoaFisica,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: forcarPessoaFisica,
                          fillColor: forcarPessoaFisica ? Colors.grey.shade200 : Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
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
                        onChanged: forcarPessoaFisica
                            ? null
                            : (valor) {
                                if (valor != null) {
                                  setState(() => _isPessoaFisica = valor);
                                }
                              },
                      ),
                      const SizedBox(height: 16),

                      BlocoIdentificacao(
                        pessoaFisica: _isPessoaFisica,
                        controllerNome: _nomeController,
                        controllerRazaoSocial: _razaoSocialController,
                        controllerCpf: _cpfController,
                        controllerCnpj: _cnpjController,
                        controllerInscricaoEstadual:
                            _inscricaoEstadualController,
                      ),

                      if (_viewModel.papelSelecionado == TipoPapel.funcionario) ...[
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                              : const Text(
                                  'Salvar Pessoa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
