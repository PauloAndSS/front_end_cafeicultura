import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/atualizar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';
import 'package:provider/provider.dart';

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
      _tamanhoValorController.text = prop.tamanho.valor.toString();
      
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

  bool _temAlteracoes() {
    final prop = _viewModel.propriedade;
    if (prop == null) return false;

    // Converte o tamanho atual para número seguro
    final tamanhoAtual = double.tryParse(_tamanhoValorController.text.replaceAll(',', '.')) ?? 0.0;
    // Remove o traço do CEP digitado para comparar com os números limpos do banco
    final cepAtualLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (_nomeController.text != prop.nome) return true;
    if (tamanhoAtual != prop.tamanho.valor) return true;
    if (_tamanhoMedida != prop.tamanho.medida) return true;
    if (cepAtualLimpo != prop.endereco.cep.numero) return true;
    if (_logradouroController.text != prop.endereco.logradouro) return true;
    if (_bairroController.text != prop.endereco.bairro) return true;
    if (_cidadeController.text != prop.endereco.cidade) return true;
    if (_ufSelecionada != prop.endereco.uf) return true;

    return false; // Retorna falso se tudo estiver exatamente igual ao banco
  }

  // 👇 NOVA FUNÇÃO: O Diálogo de confirmação de saída
  Future<bool?> _mostrarDialogoConfirmacao() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
            'Você fez modificações nos dados. Se sair agora, todas as alterações não salvas serão perdidas.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState!.validate() && _ufSelecionada != null) {
      FocusScope.of(context).unfocus();

      final sucesso = await _viewModel.atualizarPropriedadeCompleta(
        id: widget.idPropriedade,
        nome: _nomeController.text,
        tamanho: Tamanho(
          valor: double.tryParse(_tamanhoValorController.text.replaceAll(',', '.')) ?? 0.0,
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propriedade atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.mensagemErro ?? 'Erro ao atualizar propriedade.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_ufSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o Estado (UF).'), backgroundColor: Colors.red),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    // 👇 ADICIONADO: PopScope envolvendo toda a tela
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Verifica se teve mudança
        if (_temAlteracoes()) {
          final querSair = await _mostrarDialogoConfirmacao();
          if (querSair == true && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // Se não mudou nada, apenas volta sem incomodar o usuário
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF9FB896),
        appBar: AppBar(
          title: const Text('Editar Propriedade', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
            const Text('Dados Gerais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF67835C))),
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
                    validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
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
                        value: _tamanhoMedida,
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
            
            const Text('Endereço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF67835C))),
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
              label: 'Logradouro (Rua, Av.)',
              controller: _logradouroController,
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Bairro',
              controller: _bairroController,
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Cidade',
                    controller: _cidadeController,
                    validator: (value) => value == null || value.isEmpty ? 'Obrigatória' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: UfDropdown(
                    value: _ufSelecionada,
                    onChanged: (novoValor) => setState(() => _ufSelecionada = novoValor),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            CustomButton(
              text: _viewModel.isLoading ? "Salvando..." : "Salvar Alterações",
              onPressed: _viewModel.isLoading ? null : _salvarAlteracoes, 
            ),
          ],
        ),
      ),
    );
  }
}