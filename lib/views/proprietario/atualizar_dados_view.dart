import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';

class AtualizarDadosView extends StatefulWidget {
  const AtualizarDadosView({super.key});

  @override
  State<AtualizarDadosView> createState() => _AtualizarDadosViewState();
}

class _AtualizarDadosViewState extends State<AtualizarDadosView> {
  bool _isLoading = false;
  bool _isPessoaFisica = true;

  final _formKey = GlobalKey<FormState>();

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

  void atualizar(){
    //validar dados
    //atualizar dados
    //logica de trazer nome novo
  }
  @override
  void initState() {
    super.initState();
    _isLoading = true;
    try {
      _carregarDados();
    } catch (e) {
      _isLoading = false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _carregarDados() async {
    // Chama serviço que busca dados do usuario
    // Verificar o tipo de pessoa
    // Preenche os controllers
    _isPessoaFisica = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Meus Dados'),
        backgroundColor: const Color(0xFF8FA67E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                controller: _isPessoaFisica ? _cpfController : _cnpjController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _isPessoaFisica ? AppMasks.cpf : AppMasks.cnpj,
                ],
                validator: _isPessoaFisica
                    ? Validator.validarCPF
                    : Validator.validarCNPJ,
              ),

              if (!_isPessoaFisica) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Inscrição Estadual',
                  controller: _inscricaoEstadualController,
                  validator: Validator.validarInscEstadual,
                ),
              ],

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
              const Divider(height: 32, thickness: 1, color: Colors.black12),

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
                crossAxisAlignment: CrossAxisAlignment
                    .start,
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
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Obrigatório' : null,
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
                  text: 'SALVAR ALTERAÇÕES',
                  backgroundColor: const Color(0xFF8FA67E),
                  onPressed: atualizar
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
