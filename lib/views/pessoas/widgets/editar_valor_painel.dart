import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/diarista.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/detalhes_pessoa_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/validacao_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<bool> mostrarEdicaoValorHora(
  BuildContext context, {
  required Diarista diarista,
  required DetalhesPessoaViewModel viewModel,
}) {
  return _mostrarEdicaoDeValor(
    context,
    viewModel: viewModel,
    edicao: _EdicaoDeValor(
      titulo: 'Valor por hora',
      nomeDaPessoa: diarista.pessoa.nomeParaExibicao,
      sufixo: 'por hora',
      textoInicial: diarista.valorHoraParaEdicao,
      valorAtual: diarista.valorHora,
      valorAtualParaExibicao: diarista.valorHoraParaExibicao,
      mensagemObrigatorio: 'Informe o valor da hora',
      salvar: (valor) => viewModel.atualizarValorHora(diarista.id!, valor),
    ),
  );
}

Future<bool> mostrarEdicaoSalario(
  BuildContext context, {
  required Funcionario funcionario,
  required DetalhesPessoaViewModel viewModel,
}) {
  return _mostrarEdicaoDeValor(
    context,
    viewModel: viewModel,
    edicao: _EdicaoDeValor(
      titulo: 'Salário',
      nomeDaPessoa: funcionario.pessoa.nomeParaExibicao,
      sufixo: 'por mês',
      textoInicial: funcionario.salarioParaEdicao,
      valorAtual: funcionario.salario,
      valorAtualParaExibicao: funcionario.salarioParaExibicao,
      mensagemObrigatorio: 'Informe o salário',
      salvar: (valor) => viewModel.atualizarSalario(funcionario.id!, valor),
    ),
  );
}

Future<bool> _mostrarEdicaoDeValor(
  BuildContext context, {
  required DetalhesPessoaViewModel viewModel,
  required _EdicaoDeValor edicao,
}) async {
  final salvou = await mostrarPainelModal<bool>(
    context: context,
    construir: (_) =>
        _EditarValorPainel(edicao: edicao, viewModel: viewModel),
  );

  return salvou ?? false;
}

class _EdicaoDeValor {
  final String titulo;
  final String nomeDaPessoa;
  final String? sufixo;
  final String textoInicial;
  final double? valorAtual;
  final String valorAtualParaExibicao;
  final String mensagemObrigatorio;
  final Future<bool> Function(double valor) salvar;

  const _EdicaoDeValor({
    required this.titulo,
    required this.nomeDaPessoa,
    this.sufixo,
    required this.textoInicial,
    required this.valorAtual,
    required this.valorAtualParaExibicao,
    required this.mensagemObrigatorio,
    required this.salvar,
  });
}

class _EditarValorPainel extends StatefulWidget {
  final _EdicaoDeValor edicao;
  final DetalhesPessoaViewModel viewModel;

  const _EditarValorPainel({required this.edicao, required this.viewModel});

  @override
  State<_EditarValorPainel> createState() => _EditarValorPainelState();
}

class _EditarValorPainelState extends State<_EditarValorPainel> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: widget.edicao.textoInicial,
  );
  bool _tentouSalvar = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_aoDigitar);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aoDigitar() => setState(() {});

  double? get _valorDigitado => AppMasks.paraDouble(_controller.text);

  bool get _alterouValor => _valorDigitado != widget.edicao.valorAtual;

  Future<void> _salvar() async {
    if (widget.viewModel.isSalvandoValor || !_alterouValor) return;
    if (!validarRevelandoCampoInvalido(_formKey)) return;

    setState(() => _tentouSalvar = true);

    final sucesso = await widget.edicao.salvar(_valorDigitado!);

    if (sucesso && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => _construirConteudo(),
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    final salvando = widget.viewModel.isSalvandoValor;
    final erro = _tentouSalvar ? widget.viewModel.mensagemErroValor : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AlcaDoPainel(),
        CabecalhoModal(titulo: widget.edicao.titulo),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.edicao.nomeDaPessoa,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppCores.textoSecundario,
                ),
              ),
              const SizedBox(height: 20),
              Form(key: _formKey, child: _construirCampo(salvando)),
              if (erro != null) ...[
                const SizedBox(height: 16),
                CaixaAviso(
                  icone: Icons.error_outline,
                  cor: AppCores.erro,
                  corDoTexto: AppCores.erro,
                  mensagem: erro,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: salvando ? 'Salvando…' : 'Salvar valor',
                  onPressed: salvando || !_alterouValor ? null : _salvar,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirCampo(bool salvando) {
    return TextFormField(
      controller: _controller,
      autofocus: true,
      enabled: !salvando,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: [AppMasks.decimal],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (valor) =>
          Validator.valorPositivo(valor, widget.edicao.mensagemObrigatorio),
      onFieldSubmitted: (_) => _salvar(),
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppCores.textoPrimario,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        hintText: '0,00',
        prefixText: 'R\$ ',
        prefixStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppCores.textoSecundario,
        ),
        suffixText: widget.edicao.sufixo,
        suffixStyle: const TextStyle(
          fontSize: 14,
          color: AppCores.textoSecundario,
        ),
        helperText: 'Atual: ${widget.edicao.valorAtualParaExibicao}',
      ),
    );
  }
}
