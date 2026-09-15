import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/acoes_fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/widgets/campo_quantidade_comprada.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_transacao_financeira.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

Future<Insumo?> mostrarCadastroInsumo({
  required BuildContext context,
  required CarregarInsumosMixin viewModel,
  required CarregarPessoasMixin catalogoDePessoas,
  required int idPropriedade,
  List<Pessoa> fornecedores = const [],
}) {
  return showDialog<Insumo>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CadastrarInsumoDialog(
      viewModel: viewModel,
      catalogoDePessoas: catalogoDePessoas,
      idPropriedade: idPropriedade,
      fornecedores: fornecedores,
    ),
  );
}

class _CadastrarInsumoDialog extends StatefulWidget {
  final CarregarInsumosMixin viewModel;
  final CarregarPessoasMixin catalogoDePessoas;
  final int idPropriedade;
  final List<Pessoa> fornecedores;

  const _CadastrarInsumoDialog({
    required this.viewModel,
    required this.catalogoDePessoas,
    required this.idPropriedade,
    required this.fornecedores,
  });

  @override
  State<_CadastrarInsumoDialog> createState() => _CadastrarInsumoDialogState();
}

class _CadastrarInsumoDialogState extends State<_CadastrarInsumoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _qtdCompradaController = TextEditingController();
  final _valorController = TextEditingController();

  MedidaInsumo? _medidaSelecionada;
  TipoOperacao? _tipoOperacao = TransacaoFinanceira.operacaoUnica;
  FormaPagamento? _formaPagamento;
  Pessoa? _beneficiado;

  String? _erro;
  bool _salvando = false;

  late bool _semFornecedores = widget.fornecedores.isEmpty;

  Future<void> _cadastrarFornecedor() async {
    final cadastrou = await cadastrarFornecedor(context, widget.catalogoDePessoas);
    if (cadastrou && mounted) setState(() => _semFornecedores = false);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdCompradaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _erro = 'Revise os campos destacados.');
      return;
    }

    setState(() {
      _erro = null;
      _salvando = true;
    });

    final criado = await widget.viewModel.cadastrarInsumo(
      idPropriedade: widget.idPropriedade,
      descricao: _nomeController.text,
      medida: _medidaSelecionada!,
      despesa: _montarDespesa(),
      qtdComprada: AppMasks.paraDouble(_qtdCompradaController.text)!,
    );

    if (!mounted) return;

    if (criado == null) {
      setState(() {
        _salvando = false;
        _erro =
            widget.viewModel.mensagemErroInsumos ?? 'Erro ao cadastrar insumo.';
      });
      return;
    }

    Navigator.of(context).pop(criado);
  }

  Despesa _montarDespesa() {
    return Despesa(
      idPropriedade: widget.idPropriedade,
      valor: AppMasks.paraDouble(_valorController.text)!,
      formaPagamento: _formaPagamento!,
      tipoOperacao: _tipoOperacao!,
      beneficiado: _beneficiado,
      descricao: _nomeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Novo Insumo',
        style:
            TextStyle(color: AppCores.acao, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_semFornecedores) ...[
                AvisoSemFornecedor(
                  aoCadastrar: _salvando ? null : _cadastrarFornecedor,
                ),
                const SizedBox(height: 16),
              ],
              if (_erro != null) ...[
                CaixaAviso(
                  icone: Icons.error_outline,
                  cor: AppCores.erro,
                  corDoTexto: AppCores.erro,
                  mensagem: _erro!,
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                label: 'Nome do insumo',
                controller: _nomeController,
                hintText: 'Ex: Ureia Agrícola 46% N',
                validator: Validator.validarNome,
                habilitado: !_salvando,
              ),
              CampoSuspenso<MedidaInsumo>(
                rotulo: 'Unidade de medida',
                valor: _medidaSelecionada,
                itens: MedidaInsumo.values,
                rotuloItem: (medida) => medida.rotulo,
                dica: 'Selecione a medida',
                aoSelecionar: _salvando
                    ? null
                    : (valor) => setState(() => _medidaSelecionada = valor),
                validador: (valor) => valor == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CampoQuantidadeComprada(
                controller: _qtdCompradaController,
                medida: _medidaSelecionada,
                habilitado: !_salvando,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              BlocoTransacaoFinanceira(
                tipoOperacao: _tipoOperacao,
                formaPagamento: _formaPagamento,
                beneficiado: _beneficiado,
                controllerValor: _valorController,
                catalogoDePessoas: widget.catalogoDePessoas,
                categoriasBeneficiado: const [TipoPapel.fornecedor],
                habilitado: !_salvando,
                rotuloBeneficiado: 'Fornecedor',
                aoSelecionarTipoOperacao: (valor) =>
                    setState(() => _tipoOperacao = valor),
                aoSelecionarFormaPagamento: (valor) =>
                    setState(() => _formaPagamento = valor),
                aoSelecionarBeneficiado: (valor) =>
                    setState(() => _beneficiado = valor),
              ),
            ],
          ),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: _salvando ? 'Salvando...' : 'Cadastrar',
        cancelarHabilitado: !_salvando,
        aoConfirmar: _salvando || _semFornecedores ? null : _salvar,
      ),
    );
  }
}
