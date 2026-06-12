import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class CadastrarEnderecoView extends StatefulWidget {
  final Proprietario proprietario;
  final String senha;

  // Construtor exigindo os dados da tela anterior
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

  void _finalizarCadastro(){
    if (_formKey.currentState!.validate() && _ufSelecionada != null) {
      FocusScope.of(context).unfocus();
      try{
        final cep = CEP.criar(_cepController.text);
        
        final novoEndereco = Endereco(
          id: 0,
          cidade: _cidadeController.text.trim(),
          bairro: _bairroController.text.trim(),
          cep: cep,
          logradouro: _logradouroController.text.trim(),
          uf: _ufSelecionada!
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {
        // Se o CEP.criar() lançar erro (ex: tamanho inválido)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
              'Endereço da Propriedade',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF67835C)
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

            // Logradouro ocupa a linha inteira agora
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
                Expanded(
                  flex: 1,
                  child: _buildUFDropdown(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: "Finalizar Cadastro",
              onPressed: _finalizarCadastro,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUFDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UF',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<UF>(
          value: _ufSelecionada,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF67835C)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          items: UF.values.map((uf) {
            return DropdownMenuItem(
              value: uf,
              child: Text(uf.name),
            );
          }).toList(),
          onChanged: (novoUf) {
            setState(() {
              _ufSelecionada = novoUf;
            });
          },
        ),
      ],
    );
  } 
}