import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/atualizar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
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
    if (_formKey.currentState!.validate()) {
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
        backgroundColor: AppCores.verdeAuth,
        appBar: const AppBarPadrao(
          titulo: 'Editar Propriedade',
          cor: Colors.transparent,
          elevacao: 0,
        ),
        body: SafeArea(
          child: Center(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading && _viewModel.propriedade == null) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                if (_viewModel.propriedade == null) {
                  return const Text('Erro ao carregar dados.', style: TextStyle(color: Colors.white));
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dados Gerais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.verdePrimario)),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Nome da Propriedade',
              controller: _nomeController,
              validator: Validator.validarNome
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Tamanho',
                    controller: _tamanhoValorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [AppMasks.decimal],
                    validator: Validator.obrigatorio,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medida',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Medida>(
                        initialValue: _tamanhoMedida,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        ),
                        items: Medida.values.map((Medida medida) {
                          return DropdownMenuItem<Medida>(
                            value: medida,
                            child: Text(medida.name),
                          );
                        }).toList(),
                        onChanged: (Medida? novaMedida) {
                          if (novaMedida != null) {
                            setState(() => _tamanhoMedida = novaMedida);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider()),

            const Text('Endereço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.verdePrimario)),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),
            CustomButton(
              text: _viewModel.isLoading ? "Salvando..." : "Salvar Alterações",
              onPressed: _viewModel.isLoading ? null : _salvarAlteracoes,
            ),
            BotaoExcluir(
              titulo: 'Excluir Propriedade?',
              mensagem: 'Deseja realmente excluir a propriedade '
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
