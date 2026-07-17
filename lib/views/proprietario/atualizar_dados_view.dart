import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/proprietario/atualizar_dados_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';
import 'package:provider/provider.dart';

class AtualizarDadosView extends StatefulWidget {
  const AtualizarDadosView({super.key});

  @override
  State<AtualizarDadosView> createState() => _AtualizarDadosViewState();
}

class _AtualizarDadosViewState extends State<AtualizarDadosView> {
  final _viewModel = AtualizarDadosViewModel();
  bool _isPessoaFisica = true;
  bool _podeSair = false;
  final _formKey = GlobalKey<FormState>();
  Proprietario? _dadosOriginais;
  // ==========================================
  // CONTROLADORES: Dados do Proprietário/Pessoa
  // ==========================================
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  // ==========================================
  // CONTROLADORES E ESTADO: Dados do Endereço
  // ==========================================
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _paisController = TextEditingController();

  UF? _ufSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<bool> _mostrarDialogoConfirmacao() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sair sem salvar?'),
              content: const Text(
                'Se você voltar agora, todas as alterações não salvas serão perdidas. Deseja mesmo sair?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'NÃO',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'SIM, SAIR',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void atualizar() async {
    if (_formKey.currentState!.validate()) {
      if (_ufSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um Estado (UF).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);
      final idUsuario = session.idUsuario;

      if (idUsuario == null) {
        session.logout();
        return;
      }

      if (_dadosOriginais == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguarde o carregamento dos dados antes de salvar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      print("Entrou");
      final sucesso = await _viewModel.atualizar(
        dadosOriginais: _dadosOriginais!,
        idProprietario: idUsuario,
        session: session,
        isPessoaFisica: _isPessoaFisica,
        nomeOuRazao: _nomeController.text,
        emailDigitado: _emailController.text,
        telefoneDigitado: _telefoneController.text,
        cepDigitado: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufSelecionada!,
        inscEstadualDigitada: _isPessoaFisica 
            ? null 
            : _inscricaoEstadualController.text,
        cnpjDigitado: _isPessoaFisica 
            ? null 
            : _cnpjController.text,
      );
    print("Entrou2");
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ?? 'Erro desconhecido ao atualizar.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _carregarDados() async {
    final session = Provider.of<SessionViewModel>(context, listen: false);
    final idUsuario = session.idUsuario;

    if (idUsuario == null) {
      session.logout();
      return;
    }

    final dados = await _viewModel.carregarDadosProprietario(idUsuario);

    if (dados != null && mounted) {
      _dadosOriginais = dados;
      setState(() {
        _isPessoaFisica = dados.pessoa is PessoaFisica;

        _emailController.text = dados.email.endereco;
        _telefoneController.text = AppMasks.telefone.maskText(
          dados.telefone.numero,
        );

        if (_isPessoaFisica) {
          final pf = dados.pessoa as PessoaFisica;
          _nomeController.text = pf.nome;
          _cpfController.text = AppMasks.cpf.maskText(pf.cpf.numero);
        } else {
          final pj = dados.pessoa as PessoaJuridica;
          _nomeController.text = pj.razaoSocial;
          _cnpjController.text = AppMasks.cnpj.maskText(pj.cnpj.numero);
          _inscricaoEstadualController.text = pj.inscricaoEstadual ?? '';
        }

        final endereco = dados.pessoa.endereco;
        if (endereco != null) {
          _cepController.text = AppMasks.cep.maskText(endereco.cep.numero);
          _logradouroController.text = endereco.logradouro;
          _bairroController.text = endereco.bairro;
          _cidadeController.text = endereco.cidade;
          _ufSelecionada = endereco.uf;
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensagemErro ?? 'Erro desconhecido ao buscar dados.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _podeSair,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final querSair = await _mostrarDialogoConfirmacao();

        if (querSair) {
          setState(() {
            _podeSair = true;
          });
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Meus Dados'),
          backgroundColor: const Color(0xFF8FA67E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _nomeController.text.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA67E)),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: LogoCircular(size: 100.0)),
                    const SizedBox(height: 24),

                    // ==============================
                    // SEÇÃO 1: DADOS PESSOAIS
                    // ==============================
                    const Text(
                      'Dados Pessoais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: _isPessoaFisica ? 'Nome' : 'Razão Social',
                      controller: _nomeController,
                      validator: _isPessoaFisica
                          ? Validator.validarNome
                          : Validator.validarRazaoSocial,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: _isPessoaFisica ? 'CPF' : 'CNPJ',
                      controller: _isPessoaFisica
                          ? _cpfController
                          : _cnpjController,
                      readOnly: true,
                      inputFormatters: [
                        _isPessoaFisica ? AppMasks.cpf : AppMasks.cnpj,
                      ],
                      // Dica visual opcional: você pode passar uma cor de fundo cinza clara
                      // para o CustomTextField quando for readOnly para deixar óbvio para o usuário.
                    ),

                    if (!_isPessoaFisica) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Inscrição Estadual',
                        controller: _inscricaoEstadualController,
                        validator: Validator.validarInscEstadual,
                      ),
                    ],

                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.validarEmail,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Telefone',
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [AppMasks.telefone],
                      validator: Validator.validarTelefone,
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      height: 32,
                      thickness: 1,
                      color: Colors.black12,
                    ),

                    // ==============================
                    // SEÇÃO 2: ENDEREÇO
                    // ==============================
                    const Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'CEP',
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [AppMasks.cep],
                      validator: Validator.validarCEP,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Logradouro (Rua, Avenida, etc.)',
                      controller: _logradouroController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'O logradouro é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Bairro',
                      controller: _bairroController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'O bairro é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Cidade',
                      controller: _cidadeController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'A cidade é obrigatória'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: UfDropdown(
                            value: _ufSelecionada,
                            onChanged: (novoValor) {
                              setState(() {
                                _ufSelecionada = novoValor;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            label: 'País',
                            controller: _paisController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Obrigatório'
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ==============================
                    // BOTÃO
                    // ==============================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomButton(
                        text: _viewModel.isLoading
                            ? 'AGUARDE...'
                            : 'SALVAR ALTERAÇÕES',
                        backgroundColor: const Color(0xFF8FA67E),
                        onPressed: _viewModel.isLoading ? null : atualizar,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
