import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/selecionar_beneficiado_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_selecao_unica.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

class BlocoTransacaoFinanceira extends StatelessWidget {
  final TipoOperacao? tipoOperacao;
  final FormaPagamento? formaPagamento;
  final Pessoa? beneficiado;

  final TextEditingController controllerValor;
  final TextEditingController? controllerDescricao;

  final List<Pessoa> responsaveisSugeridos;
  final List<Pessoa> demaisPessoas;

  final ValueChanged<TipoOperacao?> aoSelecionarTipoOperacao;
  final ValueChanged<FormaPagamento?> aoSelecionarFormaPagamento;
  final ValueChanged<Pessoa?> aoSelecionarBeneficiado;

  final bool habilitado;
  final String dicaDescricao;
  final String rotuloBeneficiado;

  const BlocoTransacaoFinanceira({
    super.key,
    required this.tipoOperacao,
    required this.formaPagamento,
    required this.beneficiado,
    required this.controllerValor,
    this.controllerDescricao,
    required this.aoSelecionarTipoOperacao,
    required this.aoSelecionarFormaPagamento,
    required this.aoSelecionarBeneficiado,
    this.responsaveisSugeridos = const [],
    this.demaisPessoas = const [],
    this.habilitado = true,
    this.dicaDescricao = 'Ex: Pagamento de diária do tratorista',
    this.rotuloBeneficiado = 'Beneficiado',
  });

  FormaPagamento? get _formaFixada => tipoOperacao == null
      ? null
      : TransacaoFinanceira.formaUnicaPara(tipoOperacao!);

  bool get _emSacas => _formaFixada?.exigeRepasse ?? false;

  bool get _escolheForma => tipoOperacao != null && _formaFixada == null;

  bool get _escolheOperacao => TransacaoFinanceira.operacaoUnica == null;

  List<FormaPagamento> get _formasDisponiveis =>
      TransacaoFinanceira.formasPara(tipoOperacao!);

  List<Pessoa> get _beneficiadosDisponiveis {
    final idsSugeridos =
        responsaveisSugeridos.map((pessoa) => pessoa.id).toSet();

    return [
      ...responsaveisSugeridos,
      ...demaisPessoas.where((pessoa) => !idsSugeridos.contains(pessoa.id)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final descricao = controllerDescricao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_escolheOperacao) ...[
          rotuloDeCampo('Tipo de operação'),
          DropdownButtonFormField<TipoOperacao>(
            initialValue: tipoOperacao,
            isExpanded: true,
            decoration: decoracaoDeSeletor(),
            hint: dicaDeSeletor('Selecione o tipo'),
            items: TransacaoFinanceira.operacoesHabilitadas
                .map((operacao) => DropdownMenuItem(
                      value: operacao,
                      child:
                          Text(operacao.rotulo, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: habilitado ? _selecionarTipoOperacao : null,
            validator: (valor) => valor == null ? 'Obrigatório' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
        ],
        if (_escolheForma) ...[
          rotuloDeCampo('Forma de pagamento'),
          DropdownButtonFormField<FormaPagamento>(
            initialValue: formaPagamento,
            isExpanded: true,
            decoration: decoracaoDeSeletor(),
            hint: dicaDeSeletor('Selecione a forma'),
            items: _formasDisponiveis
                .map((forma) => DropdownMenuItem(
                      value: forma,
                      child: Text(forma.rotulo, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: habilitado ? aoSelecionarFormaPagamento : null,
            validator: (valor) =>
                Validator.validarFormaPagamento(valor, tipoOperacao),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
        ],
        rotuloDeCampo(_emSacas ? 'Quantidade de sacas' : 'Valor'),
        TextFormField(
          controller: controllerValor,
          enabled: habilitado,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppMasks.decimal],
          decoration: decoracaoDeSeletor().copyWith(
            hintText: '0,00',
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            prefixText: _emSacas ? null : r'R$ ',
            suffixText: _emSacas ? 'sacas' : null,
          ),
          validator: Validator.valorPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        rotuloDeCampo(rotuloBeneficiado),
        CampoSelecaoUnica<Pessoa>(
          valor: beneficiado,
          icone: Icons.person_outline,
          dica: 'Selecione o ${rotuloBeneficiado.toLowerCase()}',
          rotuloDoValor: (pessoa) => pessoa.nomeParaExibicao,
          habilitado: habilitado,
          validator: Validator.beneficiadoObrigatorio,
          aoAbrir: () => _abrirSelecaoDeBeneficiado(context),
          aoSelecionar: aoSelecionarBeneficiado,
        ),
        if (descricao != null) ...[
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Descrição',
            controller: descricao,
            hintText: dicaDescricao,
            validator: Validator.descricaoDeTransacao,
          ),
        ],
      ],
    );
  }

  void _selecionarTipoOperacao(TipoOperacao? valor) {
    aoSelecionarFormaPagamento(_formaPara(valor));
    aoSelecionarTipoOperacao(valor);
  }

  FormaPagamento? _formaPara(TipoOperacao? operacao) {
    if (operacao == null) return formaPagamento;

    final fixada = TransacaoFinanceira.formaUnicaPara(operacao);

    if (fixada != null) return fixada;

    final atual = formaPagamento;

    return atual != null && TransacaoFinanceira.combinacaoValida(atual, operacao)
        ? atual
        : null;
  }

  Future<Pessoa?> _abrirSelecaoDeBeneficiado(BuildContext context) {
    return mostrarSelecaoBeneficiado(
      context: context,
      pessoas: _beneficiadosDisponiveis,
      idsSugeridos:
          responsaveisSugeridos.map((pessoa) => pessoa.id).whereType<int>().toSet(),
      selecionadoAtual: beneficiado,
      titulo: 'Selecionar ${rotuloBeneficiado.toLowerCase()}',
      mensagemSemPessoas:
          'Nenhum ${rotuloBeneficiado.toLowerCase()} disponível.',
    );
  }
}
