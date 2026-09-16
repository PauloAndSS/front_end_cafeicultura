import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/validacao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/atualizar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_dados_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';

class AtualizarPropriedadeView extends StatefulWidget {
  final int idPropriedade;

  const AtualizarPropriedadeView({super.key, required this.idPropriedade});

  @override
  State<AtualizarPropriedadeView> createState() => _AtualizarPropriedadeViewState();
}

class _AtualizarPropriedadeViewState extends State<AtualizarPropriedadeView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = AtualizarPropriedadeViewModel();

  final _nomeController = TextEditingController();
  final _tamanhoValorController = TextEditingController();
  Medida _tamanhoMedida = Medida.hectare;

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  UF? _ufSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    _viewModel.conferirAtividades(widget.idPropriedade);

    await _viewModel.carregarPropriedade(widget.idPropriedade);

    final prop = _viewModel.propriedade;
    if (prop != null) {
      _nomeController.text = prop.nome;
      _tamanhoValorController.text = formatarDecimal(prop.tamanho.valor);

      _tamanhoMedida = prop.tamanho.medida;

      _cepController.text = prop.endereco.cep.formatado;

      _logradouroController.text = prop.endereco.logradouro;
      _bairroController.text = prop.endereco.bairro;
      _cidadeController.text = prop.endereco.cidade;

      _ufSelecionada = prop.endereco.uf;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tamanhoValorController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _excluirPropriedade() async {
    final sucesso = await _viewModel.excluir(widget.idPropriedade);

    if (!mounted) return;

    if (sucesso) {
      Provider.of<PropriedadesUsuarioViewModel>(context, listen: false)
          .carregarPropriedades();

      mostrarSucesso(context, 'Propriedade excluída com sucesso!');

      Navigator.of(context).pop();
    } else {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao excluir propriedade.');
    }
  }

  bool _temAlteracoes() {
    final prop = _viewModel.propriedade;
    if (prop == null) return false;

    final tamanhoAtual = AppMasks.paraDouble(_tamanhoValorController.text) ?? 0.0;
    final cepAtualLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (_nomeController.text != prop.nome) return true;
    if (tamanhoAtual != prop.tamanho.valor) return true;
    if (_tamanhoMedida != prop.tamanho.medida) return true;
    if (cepAtualLimpo != prop.endereco.cep.numero) return true;
    if (_logradouroController.text != prop.endereco.logradouro) return true;
    if (_bairroController.text != prop.endereco.bairro) return true;
    if (_cidadeController.text != prop.endereco.cidade) return true;
    if (_ufSelecionada != prop.endereco.uf) return true;

    return false;
  }

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      mensagem:
          'Você fez modificações nos dados. Se sair agora, todas as alterações não salvas serão perdidas.',
    );
  }
  void _salvarAlteracoes() async {
    if (validarRevelandoCampoInvalido(_formKey)) {
      FocusScope.of(context).unfocus();

      final sucesso = await _viewModel.atualizarPropriedadeCompleta(
        id: widget.idPropriedade,
        nome: _nomeController.text,
        tamanho: Tamanho(
          valor: AppMasks.paraDouble(_tamanhoValorController.text) ?? 0.0,
          medida: _tamanhoMedida,
        ),
        endereco: Endereco(
          cep: CEP.criar(_cepController.text),
          logradouro: _logradouroController.text,
          bairro: _bairroController.text,
          cidade: _cidadeController.text,
          uf: _ufSelecionada!,
          pais: 'Brasil',
        ),
      );

      if (sucesso && mounted) {
        Provider.of<PropriedadesUsuarioViewModel>(context, listen: false)
            .carregarPropriedades();

        mostrarSucesso(context, 'Propriedade atualizada com sucesso!');
        Navigator.of(context).pop();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao atualizar propriedade.');
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_temAlteracoes()) {
          final querSair = await _mostrarDialogoConfirmacao();
          if (querSair == true && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppCores.fundoAuth,
        appBar: const AppBarPadrao(
          titulo: 'Editar Propriedade',
          cor: AppCores.fundoAuth,
          elevacao: 0,
        ),
        body: SafeArea(
          child: Center(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading && _viewModel.propriedade == null) {
                  return const CircularProgressIndicator();
                }

                if (_viewModel.propriedade == null) {
                  return const Text('Erro ao carregar dados.', style: TextStyle(color: AppCores.erro));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: _buildFormCard(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return CartaoFormulario(
      filho: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tituloDeSecaoFormulario(context, 'Dados Gerais'),

            BlocoDadosPropriedade(
              controllerNome: _nomeController,
              controllerTamanho: _tamanhoValorController,
              medida: _tamanhoMedida,
              aoSelecionarMedida: (nova) =>
                  setState(() => _tamanhoMedida = nova),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(height: 1, thickness: 1, color: AppCores.borda),
            ),

            tituloDeSecaoFormulario(context, 'Endereço'),

            BlocoEndereco(
              controllerCep: _cepController,
              controllerLogradouro: _logradouroController,
              controllerBairro: _bairroController,
              controllerCidade: _cidadeController,
              uf: _ufSelecionada,
              aoSelecionarUf: (novo) => setState(() => _ufSelecionada = novo),
              dicaLogradouro: 'Rodovia, estrada, número, etc.',
              dicaBairro: 'Digite o bairro ou localidade',
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: _viewModel.isLoading ? 'Salvando...' : 'Salvar Alterações',
              onPressed: _viewModel.isLoading ? null : _salvarAlteracoes,
            ),

            if (_viewModel.temAtividades)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CaixaAvisoAtencao(
                  mensagem: 'Esta propriedade tem atividades registradas e não '
                      'pode ser excluída.',
                  itens: [
                    'Encerre os talhões e as safras para parar de lançar '
                        'atividades sem perder o histórico.',
                  ],
                ),
              )
            else if (_viewModel.sabeSeTemAtividades)
              BotaoExcluir(
                titulo: 'Excluir Propriedade?',
                mensagem:
                    'Deseja realmente excluir a propriedade '
                    '"${_nomeController.text}"? '
                    'Esta ação não poderá ser desfeita.',
                bloqueado: _viewModel.isLoading,
                aoConfirmar: _excluirPropriedade,
              ),
          ],
        ),
      ),
    );
  }
}
