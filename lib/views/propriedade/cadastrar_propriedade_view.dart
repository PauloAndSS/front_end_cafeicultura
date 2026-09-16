import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/validacao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/cadastrar_propriedade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_dados_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_endereco.dart';

class CadastrarPropriedadeView extends StatefulWidget {
  const CadastrarPropriedadeView({super.key});

  @override
  State<CadastrarPropriedadeView> createState() =>
      _CadastrarPropriedadeViewState();
}

class _CadastrarPropriedadeViewState extends State<CadastrarPropriedadeView> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CadastrarPropriedadeViewModel();

  final _nomeController = TextEditingController();
  final _tamanhoValorController = TextEditingController();
  Medida _tamanhoMedida = Medida.hectare;

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  UF? _ufSelecionada;

  bool get _houveAlteracoes {
    return _nomeController.text.isNotEmpty ||
        _tamanhoValorController.text.isNotEmpty ||
        _cepController.text.isNotEmpty ||
        _logradouroController.text.isNotEmpty ||
        _bairroController.text.isNotEmpty ||
        _cidadeController.text.isNotEmpty ||
        _ufSelecionada != null;
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

  void _salvarPropriedade() async {
    if (validarRevelandoCampoInvalido(_formKey)) {
      FocusScope.of(context).unfocus();

      final session = Provider.of<SessionViewModel>(context, listen: false);

      final resultado = await _viewModel.cadastrarPropriedade(
        session: session,
        nome: _nomeController.text,
        valorTamanho: AppMasks.paraDouble(_tamanhoValorController.text) ?? 0.0,
        medidaTamanho: _tamanhoMedida.jsonValue,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufSelecionada!,
        pais: 'Brasil',
      );

      if (resultado == true && mounted) {
        Provider.of<PropriedadesUsuarioViewModel>(context, listen: false)
            .carregarPropriedades();

        mostrarSucesso(context, 'Propriedade cadastrada com sucesso!');
        Navigator.of(context).pop();
      } else if (mounted) {
        mostrarErro(context, _viewModel.mensagemErro ??
                  'Erro desconhecido ao cadastrar propriedade.');
      }
    }
  }

  Future<bool> _mostrarDialogoConfirmacao() {
    return confirmarDescarte(
      context,
      mensagem:
          'Se você sair agora, todos os dados preenchidos serão perdidos.',
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (!_houveAlteracoes) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        final querSair = await _mostrarDialogoConfirmacao();

        if (querSair == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppCores.fundoAuth,
        appBar: const AppBarPadrao(
          titulo: 'Nova Propriedade',
          cor: AppCores.fundoAuth,
          elevacao: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  const LogoCircular(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                ],
              ),
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

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return CustomButton(
                  text: _viewModel.isLoading ? 'Salvando...' : 'Salvar',
                  onPressed: _viewModel.isLoading ? null : _salvarPropriedade,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
