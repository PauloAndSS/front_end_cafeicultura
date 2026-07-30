import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/cadastrar_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';

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
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data de início do talhão',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF67835C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione a data de início'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_variedadesSelecionadas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos uma variedade'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();

      final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
      
      if (propriedadesVM.idPropriedadeSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma propriedade selecionada.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final List<int> idsVariedades = _variedadesSelecionadas
          .map((v) => v.id)
          .toList();

      final novoTalhao = Talhao(
        nome: _nomeController.text.trim(),
        idPropriedade: propriedadesVM.idPropriedadeSelecionada!,
        qtdPeCafe: int.tryParse(_qtdPesController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        
        dataInicio: _dataInicio!,
        tamanho: Tamanho(
          valor: double.tryParse(_tamanhoController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0,
          medida: _tamanhoMedida,
        ),
        especie: _especieSelecionada!,
        variedadesIds: idsVariedades,
      );

      final resultado = await _viewModel.cadastrarTalhao(novoTalhao);

      if (resultado == true && mounted) {
        context.read<TalhoesViewModel>().carregarTalhoes(propriedadesVM.idPropriedadeSelecionada!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talhão cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ?? 'Erro desconhecido ao cadastrar talhão.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Novo Talhão', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF67835C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Envolvemos com ListenableBuilder (ou AnimatedBuilder) para re-renderizar quando o ViewModel mudar de estado
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
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Obrigatório' : null,
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
                            inputFormatters: [AppMasks.inteiroMilhar],
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Obrigatório' : null,
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
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),

                    GestureDetector(
                      onTap: () => _selecionarData(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: 'Data de Início',
                          controller: _dataController,
                          hintText: 'Selecione a data',
                          readOnly: true,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
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
                          child: Text(
                            especie[0].toUpperCase() + especie.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _especieSelecionada = val;
                          _variedadesSelecionadas.clear();
                        });
                      },
                      validator: (val) => val == null ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Variedades',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF67835C),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _viewModel.isLoadingVariedades
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: Color(0xFF67835C)),
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
                            :  Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    // Adicionamos o .where para filtrar antes de mapear
    children: _viewModel.variedades
        .where((variedade) {
          // Supondo que o atributo no modelo Variedade se chame 'especie' ou 'tipo'
          // É importante que o texto retornado pela API/Modelo seja exatamente igual
          // ao que está no Dropdown ('Conilon' ou 'Arábica'). 
          // Se houver diferença de maiúsculas/minúsculas, use .toLowerCase() em ambos.
          return variedade.especie == _especieSelecionada; 
        })
        .map((variedade) {
      final isSelected = _variedadesSelecionadas.contains(
        variedade,
      );
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
        selectedColor: const Color(0xFF8FA67E),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _variedadesSelecionadas.add(variedade);
            } else {
              _variedadesSelecionadas.remove(variedade);
            }
          });
        },
      );
    }).toList(),
  ),

                    const SizedBox(height: 32),

                    CustomButton(
                      text: _viewModel.isLoading ? 'Salvando...' : 'Salvar Talhão',
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