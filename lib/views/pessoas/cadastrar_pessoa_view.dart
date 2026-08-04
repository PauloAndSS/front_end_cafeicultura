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

class CadastrarPessoaView extends StatefulWidget {
  const CadastrarPessoaView({super.key});

  @override
  State<CadastrarPessoaView> createState() => _CadastrarPessoaViewState();
}

class _CadastrarPessoaViewState extends State<CadastrarPessoaView> {
  final _viewModel = CadastroPessoaViewModel();
  final _formKey = GlobalKey<FormState>();

  bool _isPessoaFisica = true;

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _inscricaoEstadualController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  bool _temDadosAlterados() {
    return _nomeController.text.isNotEmpty ||
        _cpfController.text.isNotEmpty ||
        _razaoSocialController.text.isNotEmpty ||
        _cnpjController.text.isNotEmpty ||
        _inscricaoEstadualController.text.isNotEmpty ||
        _viewModel.papelSelecionado != null;
  }

  Future<bool> _mostrarDialogoConfirmacao() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Você preencheu alguns dados. Se sair agora, tudo será perdido. Deseja realmente sair?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continuar Editando',
              style: TextStyle(
                color: Color(0xFF8FA67E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair sem Salvar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final bool isPessoaFisica = _razaoSocialController.text.trim().isEmpty;

      final pessoaBase = isPessoaFisica
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

      dynamic objetoPapel;
      switch (_viewModel.papelSelecionado) {
        case TipoPapelCadastro.funcionario:
          objetoPapel = Funcionario(pessoa: pessoaBase);
          break;
        case TipoPapelCadastro.meeiro:
          objetoPapel = Meeiro(pessoa: pessoaBase);
          break;
        case TipoPapelCadastro.fornecedor:
          objetoPapel = Fornecedor(pessoa: pessoaBase);
          break;
        case TipoPapelCadastro.prestador:
          objetoPapel = PrestadorDeServico(pessoa: pessoaBase);
          break;
        case TipoPapelCadastro.cliente:
          objetoPapel = Cliente(pessoa: pessoaBase);
          break;
        case null:
          break;
      }

      final sucesso = await _viewModel.cadastrarPessoa(
        objetoPapel: objetoPapel,
      );

      if (sucesso && mounted) {
        Navigator.pop(context, true);
      } else if (mounted && _viewModel.mensagemErro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.mensagemErro!),
            backgroundColor: Colors.red,
          ),
        );
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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF9FB896),
          title: const Text('Cadastrar Pessoa'),
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
                      DropdownButtonFormField<TipoPapelCadastro>(
                        value: _viewModel.papelSelecionado,
                        hint: const Text('Selecione o papel'),
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
                            value: TipoPapelCadastro.funcionario,
                            child: Text('Funcionário'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapelCadastro.meeiro,
                            child: Text('Meeiro'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapelCadastro.fornecedor,
                            child: Text('Fornecedor'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapelCadastro.prestador,
                            child: Text('Prestador de Serviço'),
                          ),
                          DropdownMenuItem(
                            value: TipoPapelCadastro.cliente,
                            child: Text('Cliente'),
                          ),
                        ],
                        onChanged: (papel) => _viewModel.selecionarPapel(papel),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _isPessoaFisica = valor);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_isPessoaFisica) ...[
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                          ),
                          validator: Validator.validarNome,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [AppMasks.cpf],
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                          ),
                          validator: Validator.validarCPF,
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _razaoSocialController,
                          decoration: const InputDecoration(
                            labelText: 'Razão Social',
                          ),
                          validator: Validator.validarRazaoSocial,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cnpjController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [AppMasks.cnpj],
                          decoration: const InputDecoration(
                            labelText: 'CNPJ',
                            hintText: '00.000.000/0000-00',
                          ),
                          validator: Validator.validarCNPJ,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _inscricaoEstadualController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Inscrição Estadual (Opcional)',
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8FA67E),
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
