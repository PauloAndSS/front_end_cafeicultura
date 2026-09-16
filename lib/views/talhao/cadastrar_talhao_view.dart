import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/validacao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/cadastrar_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_de_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

class CadastrarTalhaoView extends StatefulWidget {
  const CadastrarTalhaoView({super.key});

  @override
  State<CadastrarTalhaoView> createState() => _CadastrarTalhaoViewState();
}

class _CadastrarTalhaoViewState extends State<CadastrarTalhaoView> {
  final _formKey = GlobalKey<FormState>();

  final _chaveVariedades = GlobalKey();

  final _nomeController = TextEditingController();
  final _tamanhoController = TextEditingController();
  final _qtdPesController = TextEditingController();
  final _dataController = TextEditingController();

  Medida _tamanhoMedida = Medida.hectare;
  DateTime? _dataInicio;
  String? _especieSelecionada;
  final List<Variedade> _variedadesSelecionadas = [];

  final _viewModel = CadastrarTalhaoViewModel();

  final List<String> _opcoesEspecie = ['Conilon', 'Arábica'];

  @override
  void initState() {
    super.initState();
    _viewModel.carregarVariedades();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tamanhoController.dispose();
    _qtdPesController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final dataEscolhida = await selecionarData(
      context: context,
      ajuda: 'Selecione a data de início do talhão',
      inicial: _dataInicio,
    );

    if (dataEscolhida != null && dataEscolhida != _dataInicio) {
      setState(() {
        _dataInicio = dataEscolhida;
        _dataController.text =
            '${dataEscolhida.day.toString().padLeft(2, '0')}/${dataEscolhida.month.toString().padLeft(2, '0')}/${dataEscolhida.year}';
      });
    }
  }

  Future<void> _salvar() async {
    if (validarRevelandoCampoInvalido(_formKey)) {
      if (_dataInicio == null) {
        mostrarAviso(context, 'Selecione a data de início');
        return;
      }
      if (_variedadesSelecionadas.isEmpty) {
        revelarCampo(_chaveVariedades.currentContext);
        mostrarAviso(context, 'Selecione pelo menos uma variedade');
        return;
      }

      FocusScope.of(context).unfocus();

      final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();

      if (propriedadesVM.idPropriedadeSelecionada == null) {
        mostrarAviso(context, 'Nenhuma propriedade selecionada.');
        return;
      }

      final List<int> idsVariedades = _variedadesSelecionadas
          .map((v) => v.id)
          .toList();

      final novoTalhao = Talhao(
        nome: _nomeController.text.trim(),
        idPropriedade: propriedadesVM.idPropriedadeSelecionada!,
        qtdPeCafe:
            int.tryParse(
              _qtdPesController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        dataInicio: _dataInicio!,
        tamanho: Tamanho(
          valor:
              double.tryParse(
                _tamanhoController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.'),
              ) ??
              0.0,
          medida: _tamanhoMedida,
        ),
        especie: _especieSelecionada!,
        variedadesIds: idsVariedades,
      );

      final resultado = await _viewModel.cadastrarTalhao(novoTalhao);

      if (resultado == true && mounted) {
        context.read<TalhoesViewModel>().carregarTalhoes(
          propriedadesVM.idPropriedadeSelecionada!,
        );

        mostrarSucesso(context, 'Talhão cadastrado com sucesso!');
        Navigator.of(context).pop();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar talhão.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: const AppBarPadrao(titulo: 'Novo Talhão'),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppCores.superficie,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppEstilos.sombraCartao,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nome do Talhão',
                      controller: _nomeController,
                      validator: Validator.obrigatorio,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Tamanho',
                            controller: _tamanhoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [AppMasks.decimal],
                            validator: Validator.obrigatorio,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CampoSuspenso<Medida>(
                            rotulo: 'Medida',
                            valor: _tamanhoMedida,
                            itens: Medida.values,
                            rotuloItem: (medida) => medida.nomeExibicao,
                            aoSelecionar: (val) {
                              if (val != null) {
                                setState(() => _tamanhoMedida = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    CustomTextField(
                      label: 'Quantidade de Pés de Café',
                      controller: _qtdPesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [AppMasks.inteiroMilhar],
                      validator: Validator.obrigatorio,
                    ),

                    CampoDeData(
                      label: 'Data de Início',
                      controller: _dataController,
                      aoTocar: () => _selecionarData(context),
                    ),

                    const Divider(),
                    const SizedBox(height: 16),

                    CampoSuspenso<String>(
                      rotulo: 'Espécie',
                      valor: _especieSelecionada,
                      itens: _opcoesEspecie,
                      rotuloItem: (especie) => especie,
                      dica: 'Selecione',
                      aoSelecionar: (val) {
                        setState(() {
                          _especieSelecionada = val;
                          _variedadesSelecionadas.clear();
                        });
                      },
                      validador: (val) => val == null ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    KeyedSubtree(
                      key: _chaveVariedades,
                      child: const Text(
                        'Variedades',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppCores.acao,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _viewModel.isLoadingVariedades
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _especieSelecionada == null
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppCores.fundo,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Selecione a espécie primeiro.',
                              style: TextStyle(color: AppCores.textoSecundario),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _viewModel.variedades
                                .where((variedade) {
                                  final especieTalhao = _especieSelecionada!
                                      .toLowerCase()
                                      .trim();
                                  final especieVar = variedade.especie
                                      .toLowerCase()
                                      .trim();

                                  return especieVar == especieTalhao ||
                                      especieVar == 'mista';
                                })
                                .map((variedade) {
                                  final isSelected = _variedadesSelecionadas
                                      .contains(variedade);
                                  return FilterChip(
                                    label: Text(
                                      variedade.descricao,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppCores.sobreAcao
                                            : AppCores.textoPrimario,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppCores.acao,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _variedadesSelecionadas.add(
                                            variedade,
                                          );
                                        } else {
                                          _variedadesSelecionadas.remove(
                                            variedade,
                                          );
                                        }
                                      });
                                    },
                                  );
                                })
                                .toList(),
                          ),

                    const SizedBox(height: 32),

                    CustomButton(
                      text: _viewModel.isLoading
                          ? 'Salvando...'
                          : 'Salvar Talhão',
                      onPressed: _viewModel.isLoading ? null : _salvar,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
