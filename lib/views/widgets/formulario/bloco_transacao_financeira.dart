import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/selecionar_beneficiado_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_selecao_unica.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class BlocoTransacaoFinanceira extends StatelessWidget {
  final TipoOperacao? tipoOperacao;
  final FormaPagamento? formaPagamento;
  final Pessoa? beneficiado;

  final TextEditingController controllerValor;

  final List<Pessoa> responsaveisSugeridos;

  /// O catálogo de pessoas que a seleção do beneficiado navega, e as
  /// categorias que ela oferece. Quem lança despesa de atividade abre as cinco;
  /// o cadastro de insumo abre só fornecedores, e aí o painel nem desenha aba.
  final CarregarPessoasMixin catalogoDePessoas;
  final List<TipoPapel> categoriasBeneficiado;

  final ValueChanged<TipoOperacao?> aoSelecionarTipoOperacao;
  final ValueChanged<FormaPagamento?> aoSelecionarFormaPagamento;
  final ValueChanged<Pessoa?> aoSelecionarBeneficiado;

  final bool habilitado;
  final String rotuloBeneficiado;

  const BlocoTransacaoFinanceira({
    super.key,
    required this.tipoOperacao,
    required this.formaPagamento,
    required this.beneficiado,
    required this.controllerValor,
    required this.aoSelecionarTipoOperacao,
    required this.aoSelecionarFormaPagamento,
    required this.aoSelecionarBeneficiado,
    required this.catalogoDePessoas,
    required this.categoriasBeneficiado,
    this.responsaveisSugeridos = const [],
    this.habilitado = true,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_escolheOperacao) ...[
          CampoSuspenso<TipoOperacao>(
            rotulo: 'Tipo de operação',
            valor: tipoOperacao,
            itens: TransacaoFinanceira.operacoesHabilitadas,
            rotuloItem: (operacao) => operacao.rotulo,
            dica: 'Selecione o tipo',
            aoSelecionar: habilitado ? _selecionarTipoOperacao : null,
            validador: (valor) => valor == null ? 'Obrigatório' : null,
          ),
          const SizedBox(height: 16),
        ],
        if (_escolheForma) ...[
          CampoSuspenso<FormaPagamento>(
            rotulo: 'Forma de pagamento',
            valor: formaPagamento,
            itens: _formasDisponiveis,
            rotuloItem: (forma) => forma.rotulo,
            dica: 'Selecione a forma',
            aoSelecionar: habilitado ? aoSelecionarFormaPagamento : null,
            validador: (valor) =>
                Validator.validarFormaPagamento(valor, tipoOperacao),
          ),
          const SizedBox(height: 16),
        ],
        rotuloDeCampo(context, _emSacas ? 'Quantidade de sacas' : 'Valor'),
        TextFormField(
          controller: controllerValor,
          enabled: habilitado,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppMasks.decimal],
          decoration: InputDecoration(
            hintText: '0,00',
            hintStyle: const TextStyle(color: AppCores.textoTerciario, fontSize: 14),
            prefixText: _emSacas ? null : r'R$ ',
            suffixText: _emSacas ? 'sacas' : null,
          ),
          validator: Validator.valorPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        rotuloDeCampo(context, rotuloBeneficiado),
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
      catalogo: catalogoDePessoas,
      categorias: categoriasBeneficiado,
      sugeridos: responsaveisSugeridos,
      selecionadoAtual: beneficiado,
      titulo: 'Selecionar ${rotuloBeneficiado.toLowerCase()}',
    );
  }
}
