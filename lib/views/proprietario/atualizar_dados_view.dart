import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/proprietario/atualizar_dados_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_contato.dart';

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
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
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

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      titulo: 'Sair sem salvar?',
      mensagem:
          'Se você voltar agora, todas as alterações não salvas serão perdidas. Deseja mesmo sair?',
    );
  }
  void atualizar() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);
      final idUsuario = session.idUsuario;

      if (idUsuario == null) {
        session.logout();
        return;
      }

      if (_dadosOriginais == null) {
        mostrarAviso(context, 'Aguarde o carregamento dos dados antes de salvar.');
        return;
      }
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
        pais: _paisController.text,
        uf: _ufSelecionada!,
        inscEstadualDigitada: _isPessoaFisica
            ? null
            : _inscricaoEstadualController.text,
        cnpjDigitado: _isPessoaFisica
            ? null
            : _cnpjController.text,
      );
      if (sucesso && mounted) {
        mostrarSucesso(context, 'Dados atualizados com sucesso!');
        Navigator.of(context).pop();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ?? 'Erro desconhecido ao atualizar.');
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
          _paisController.text = endereco.pais!;
        }
      });
    } else if (mounted) {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro desconhecido ao buscar dados.');
    }
  }

  bool _houveAlteracao() {
    if (_dadosOriginais == null) return false;

    if (_emailController.text.trim() != _dadosOriginais!.email.endereco) return true;

    final telMasked = AppMasks.telefone.maskText(_dadosOriginais!.telefone.numero);
    if (_telefoneController.text.trim() != telMasked) return true;

    if (_isPessoaFisica) {
      final pf = _dadosOriginais!.pessoa as PessoaFisica;
      if (_nomeController.text.trim() != pf.nome) return true;
    } else {
      final pj = _dadosOriginais!.pessoa as PessoaJuridica;
      if (_nomeController.text.trim() != pj.razaoSocial) return true;
      if (_inscricaoEstadualController.text.trim() != (pj.inscricaoEstadual ?? '')) return true;
    }

    final endereco = _dadosOriginais!.pessoa.endereco;
    if (endereco == null) {
      if (_cepController.text.isNotEmpty ||
          _logradouroController.text.isNotEmpty ||
          _bairroController.text.isNotEmpty ||
          _cidadeController.text.isNotEmpty ||
          _paisController.text.isNotEmpty ||
          _ufSelecionada != null) {
        return true;
      }
    } else {
      final cepMasked = AppMasks.cep.maskText(endereco.cep.numero);
      if (_cepController.text.trim() != cepMasked) return true;
      if (_logradouroController.text.trim() != endereco.logradouro) return true;
      if (_bairroController.text.trim() != endereco.bairro) return true;
      if (_cidadeController.text.trim() != endereco.cidade) return true;
      if (_ufSelecionada != endereco.uf) return true;
      if (_paisController.text.trim() != (endereco.pais ?? '')) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
return PopScope(
      canPop: _podeSair,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (!_houveAlteracao()) {
          setState(() {
            _podeSair = true;
          });
          if (mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

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
        backgroundColor: AppCores.fundo,
        appBar: const AppBarPadrao(
          titulo: 'Meus Dados',
          cor: AppCores.verdeSecundario,
          elevacao: 0,
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _nomeController.text.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppCores.verdeSecundario),
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
                    BlocoContato(
                      controllerEmail: _emailController,
                      controllerTelefone: _telefoneController,
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      height: 32,
                      thickness: 1,
                      color: Colors.black12,
                    ),

                    const Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    BlocoEndereco(
                      controllerCep: _cepController,
                      controllerLogradouro: _logradouroController,
                      controllerBairro: _bairroController,
                      controllerCidade: _cidadeController,
                      controllerPais: _paisController,
                      uf: _ufSelecionada,
                      aoSelecionarUf: (novo) =>
                          setState(() => _ufSelecionada = novo),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomButton(
                        text: _viewModel.isLoading
                            ? 'AGUARDE...'
                            : 'SALVAR ALTERAÇÕES',
                        backgroundColor: AppCores.verdeSecundario,
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
