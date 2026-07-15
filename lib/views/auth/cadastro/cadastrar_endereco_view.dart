import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/cadastro/cadastrar_endereco_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';
import 'package:provider/provider.dart';

class CadastrarEnderecoView extends StatefulWidget {
  final Proprietario proprietario;
  final String senha;

  const CadastrarEnderecoView({
    super.key,
    required this.proprietario,
    required this.senha,
  });

  @override
  State<CadastrarEnderecoView> createState() => CadastrarEnderecoViewState();
}

class CadastrarEnderecoViewState extends State<CadastrarEnderecoView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CadastrarEnderecoViewmodel(
    service: ServicesProprietario(),
  );
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  UF? _ufSelecionada;

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _finalizarCadastroComEndereco() async {
    if (_formKey.currentState!.validate() && _ufSelecionada != null) {
      FocusScope.of(context).unfocus();
    final session = Provider.of<SessionViewModel>(context, listen: false);

      final proprietarioSalvo = await _viewModel.finalizarCadastroComEndereco(
        proprietarioSemEndereco: widget.proprietario,
        senha: widget.senha,
        cepDigitado: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufSelecionada!,
        session: session,
      );

      if (proprietarioSalvo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ?? 'Erro desconhecido ao cadastrar.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        if(_viewModel.erroDaPagAnterior == true){
        Navigator.pop(context);
      }
      }
    } else if (_ufSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o Estado (UF).'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _finalizarCadastroSemEndereco() async {
    FocusScope.of(context).unfocus();

    final proprietarioSalvo = await _viewModel.finalizarCadastroSemEndereco(
      proprietario: widget.proprietario,
      senha: widget.senha,
      session: Provider.of<SessionViewModel>(context, listen: false),
    );

    if (proprietarioSalvo != null && mounted) {
      final proprietario = proprietarioSalvo.pessoa;
      String nomeParaLogar = 'Produtor';

      if (proprietario is PessoaFisica) {
        nomeParaLogar = proprietario.nome;
      } 
      else if (proprietario is PessoaJuridica) {
        nomeParaLogar = proprietario.razaoSocial;
      }
      final session = Provider.of<SessionViewModel>(context, listen: false);
      
      await session.login(
        proprietarioSalvo.id ?? 0, 
        nomeParaLogar,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensagemErro ?? 'Erro ao finalizar cadastro.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      if(_viewModel.erroDaPagAnterior == true){
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9FB896),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                const LogoCircular(),
                const SizedBox(height: 24),
                _buildEnderecoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnderecoCard() {
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
            const Text(
              'Seu Endereço',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF67835C),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'CEP',
              controller: _cepController,
              keyboardType: TextInputType.number,
              validator: Validator.validarCEP,
              inputFormatters: [AppMasks.cep],
              hintText: 'Digite o CEP (apenas números)',
            ),

            CustomTextField(
              label: 'Logradouro',
              controller: _logradouroController,
              validator: Validator.validarNome,
              hintText: 'Rua, Avenida, número, complemento...',
            ),

            CustomTextField(
              label: 'Bairro',
              controller: _bairroController,
              validator: Validator.validarNome,
              hintText: 'Digite o bairro ou distrito',
            ),

Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Cidade',
                    controller: _cidadeController,
                    validator: Validator.validarNome,
                    hintText: 'Nome da cidade',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 1, child: UfDropdown(
                  value: _ufSelecionada,
                  onChanged: (UF? newValue) {
                    setState(() {
                      _ufSelecionada = newValue;
                    });
                  },
                )),
              ],
            ),

            const SizedBox(height: 24),

            // 👇 TRECHO CORRIGIDO 👇
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                // 1. Retorna o loading centralizado
                if (_viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF67835C)),
                  );
                }
                
                // 2. Retorna TODOS os botões agrupados dentro de uma Column
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      text: "Finalizar Cadastro",
                      onPressed: _finalizarCadastroComEndereco,
                    ),
                    
                    const SizedBox(height: 12), // Ajustado para height e usando vírgula
                    
                    CustomButton(
                      text: "Adicionar endereço depois", 
                      onPressed: _finalizarCadastroSemEndereco,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF67835C),
                    ),
                  ],
                );
              },
            ),
            // 👆 FIM DO TRECHO CORRIGIDO 👆
            
          ],
        ),
      ),
    );
  }
}
