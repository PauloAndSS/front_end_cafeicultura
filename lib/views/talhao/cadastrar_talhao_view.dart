import 'package:flutter/material.dart';
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
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';

class CadastrarTalhaoView extends StatefulWidget {
  const CadastrarTalhaoView({super.key});

  @override
  State<CadastrarTalhaoView> createState() => _CadastrarTalhaoViewState();
}

class _CadastrarTalhaoViewState extends State<CadastrarTalhaoView> {
  final _formKey = GlobalKey<FormState>();

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
    if (_formKey.currentState!.validate()) {
      if (_dataInicio == null) {
        mostrarAviso(context, 'Selecione a data de início');
        return;
      }
      if (_variedadesSelecionadas.isEmpty) {
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppCores.borda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppCores.borda),
      ),
    );
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      label: 'Nome do Talhão',
                      controller: _nomeController,
                      validator: Validator.obrigatorio,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
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
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medida',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<Medida>(
                                value: _tamanhoMedida,
                                isExpanded: true,
                                decoration: _dropdownDecoration(),
                                items: Medida.values.map((medida) {
                                  return DropdownMenuItem(
                                    value: medida,
                                    child: Text(
                                      medida.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _tamanhoMedida = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
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

                    const Text(
                      'Espécie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _especieSelecionada,
                      decoration: _dropdownDecoration(),
                      hint: const Text(
                        'Selecione',
                        style: TextStyle(color: Colors.black26, fontSize: 14),
                      ),
                      items: _opcoesEspecie.map((especie) {
                        return DropdownMenuItem(
                          value: especie,
                          child: Text(especie),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _especieSelecionada = val;
                          _variedadesSelecionadas.clear();
                        });
                      },
                      validator: (val) => val == null ? 'Obrigatório' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Variedades',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppCores.verdePrimario,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _viewModel.isLoadingVariedades
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                color: AppCores.verdePrimario,
                              ),
                            ),
                          )
                        : _especieSelecionada == null
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Selecione a espécie primeiro.',
                              style: TextStyle(color: Colors.grey),
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
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppCores.verdeSecundario,
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
