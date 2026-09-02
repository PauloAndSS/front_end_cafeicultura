import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/transacao_financeira_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/detalhes_despesa_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/dados_formulario_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/periodo.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/cadastrar_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/selecionar_responsaveis_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_de_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';

class FormularioAtividadeView extends StatefulWidget {
  final CadastrarAtividadeViewModel viewModel;

  final DateTime? dataInicial;

  final DadosFormularioAtividade? valoresIniciais;

  final String titulo;
  final String rotuloBotaoSalvar;
  final String mensagemSucesso;

  final String ajudaDataInicio;
  final String ajudaDataFim;

  final String dicaDataFim;

  final String mensagemSemTalhoes;

  final String mensagemSemSafras;

  final String mensagemSemJanela;

  final WidgetBuilder? construirCamposEspecificos;

  final WidgetBuilder? construirCamposFinais;

  final bool Function()? validarCamposEspecificos;

  final bool camposEspecificosPreenchidos;

  final Future<bool> Function(DadosFormularioAtividade dados) aoSalvar;

  const FormularioAtividadeView({
    super.key,
    required this.viewModel,
    required this.titulo,
    required this.rotuloBotaoSalvar,
    required this.mensagemSucesso,
    required this.ajudaDataInicio,
    required this.ajudaDataFim,
    required this.dicaDataFim,
    required this.mensagemSemTalhoes,
    required this.mensagemSemSafras,
    required this.mensagemSemJanela,
    required this.aoSalvar,
    this.dataInicial,
    this.valoresIniciais,
    this.construirCamposEspecificos,
    this.construirCamposFinais,
    this.validarCamposEspecificos,
    this.camposEspecificosPreenchidos = false,
  });

  @override
  State<FormularioAtividadeView> createState() =>
      _FormularioAtividadeViewState();
}

class _FormularioAtividadeViewState extends State<FormularioAtividadeView> {
  final _formKey = GlobalKey<FormState>();

  final _descricaoController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  Talhao? _talhaoSelecionado;

  Safra? _safraSelecionada;

  DateTime? _dataInicio;
  DateTime? _dataFim;

  List<Periodo> _janelas = const [];

  bool _conferiuDataInicial = false;

  bool _semeouEscopo = false;

  List<Pessoa> _responsaveisSelecionados = [];

  List<Despesa> _despesas = [];

  bool _salvou = false;

  CadastrarAtividadeViewModel get _viewModel => widget.viewModel;

  bool _descricaoPreenchida = false;

  @override
  void initState() {
    super.initState();

    _semearValoresIniciais();

    _descricaoPreenchida = _descricaoController.text.trim().isNotEmpty;
    _descricaoController.addListener(_aoDigitarDescricao);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.init(context.read<PropriedadesUsuarioViewModel>());
      }
    });
  }

  void _semearValoresIniciais() {
    final iniciais = widget.valoresIniciais;

    if (iniciais == null) {
      if (widget.dataInicial != null) {
        _dataInicio = widget.dataInicial;
        _dataInicioController.text = formatarDataBr(widget.dataInicial!);
      }

      return;
    }

    _dataInicio = iniciais.dataInicio;
    _dataInicioController.text = formatarDataBr(iniciais.dataInicio);

    final dataFim = iniciais.dataFim;

    if (dataFim != null) {
      _dataFim = dataFim;
      _dataFimController.text = formatarDataBr(dataFim);
    }

    _descricaoController.text = iniciais.descricao?.trim() ?? '';
    _responsaveisSelecionados = [...iniciais.responsaveis];
    _despesas = [...iniciais.despesas];
  }

  void _semearEscopo(List<Talhao> talhoes, List<Safra> safras) {
    final iniciais = widget.valoresIniciais;

    if (iniciais == null || _semeouEscopo) return;
    if (talhoes.isEmpty || safras.isEmpty) return;

    for (final talhao in talhoes) {
      if (talhao.id == iniciais.idTalhao) _talhaoSelecionado = talhao;
    }

    for (final safra in safras) {
      if (safra.id == iniciais.idSafra) _safraSelecionada = safra;
    }

    _semeouEscopo = true;
  }

  void _aoDigitarDescricao() {
    final preenchida = _descricaoController.text.trim().isNotEmpty;

    if (preenchida != _descricaoPreenchida) {
      setState(() => _descricaoPreenchida = preenchida);
    }
  }

  @override
  void dispose() {
    _descricaoController.removeListener(_aoDigitarDescricao);
    _descricaoController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  bool get _temAlteracoes {
    final iniciais = widget.valoresIniciais;

    if (iniciais == null) {
      return _talhaoSelecionado != null ||
          _safraSelecionada != null ||
          _dataInicio != widget.dataInicial ||
          _descricaoPreenchida ||
          _responsaveisSelecionados.isNotEmpty ||
          _despesas.isNotEmpty ||
          widget.camposEspecificosPreenchidos;
    }

    return _dataInicio != iniciais.dataInicio ||
        _dataFim != iniciais.dataFim ||
        _talhaoSelecionado?.id != iniciais.idTalhao ||
        _safraSelecionada?.id != iniciais.idSafra ||
        _descricaoController.text.trim() != (iniciais.descricao?.trim() ?? '') ||
        _responsaveisSelecionados.length != iniciais.responsaveis.length ||
        _despesas.length != iniciais.despesas.length;
  }

  void _recarregarDados() {
    final propriedadesViewModel = context.read<PropriedadesUsuarioViewModel>();

    _viewModel.init(propriedadesViewModel);

    final idPropriedade = propriedadesViewModel.idPropriedadeSelecionada;
    if (idPropriedade == null) return;

    context.read<SafraViewModel>().carregarDadosDaPropriedade(
          idPropriedade,
          forcarAtualizacao: true,
        );
  }

  List<Talhao> _talhoesDisponiveis() =>
      _dataInicio == null ? const [] : _viewModel.talhoesAbertosEm(_dataInicio!);

  List<Safra> _safrasDisponiveis(SafraViewModel safraViewModel) =>
      _dataInicio == null
          ? const []
          : safraViewModel.safrasAbertasEm(_dataInicio!);

  Talhao? _resolverTalhao(List<Talhao> disponiveis) {
    if (disponiveis.length == 1) return disponiveis.first;

    final escolhido = _talhaoSelecionado;

    if (escolhido == null) return null;

    for (final talhao in disponiveis) {
      if (talhao.id == escolhido.id) return talhao;
    }

    return null;
  }

  Talhao? _talhaoDoLancamento() => _resolverTalhao(_talhoesDisponiveis());

  Safra? _resolverSafra(List<Safra> disponiveis) {
    if (disponiveis.length == 1) return disponiveis.first;

    return disponiveis.contains(_safraSelecionada) ? _safraSelecionada : null;
  }

  Safra? _safraDoLancamento() =>
      _resolverSafra(_safrasDisponiveis(context.read<SafraViewModel>()));

  bool get _ehRetroativa => _dataInicio != null && !ehFutura(_dataInicio!);

  bool get _aceitaDataFim => _ehRetroativa;

  DateTime? _fimDoEscopo(Talhao? talhao, Safra? safra) =>
      menorData(talhao?.dataFim, safra?.dataFim);

  bool _dataFimObrigatoria(Talhao? talhao, Safra? safra) =>
      _fimDoEscopo(talhao, safra) != null;

  DateTime _tetoDataFim(Talhao? talhao, Safra? safra) =>
      menorData(hoje(), _fimDoEscopo(talhao, safra)) ?? hoje();

  Future<void> _selecionarDataInicio() async {
    if (_janelas.isEmpty) return;

    final escolhida = await selecionarData(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: _diaValidoMaisProximo(_dataInicio ?? hoje()),
      minima: _primeiroDiaLancavel,
      maxima: menorData(limiteAgendamento, _ultimoDiaLancavel),
      diaSelecionavel: _aceitaDia,
    );

    if (escolhida == null || !mounted) return;

    setState(() {
      _dataInicio = escolhida;
      _dataInicioController.text = formatarDataBr(escolhida);

      _descartarEscopoForaDaData(escolhida);
      _ajustarDataFimAoEscopo();
    });
  }

  void _descartarEscopoForaDaData(DateTime dia) {
    if (_talhaoSelecionado != null && !_talhaoSelecionado!.periodo.contem(dia)) {
      _talhaoSelecionado = null;
    }

    if (_safraSelecionada != null &&
        !(_safraSelecionada!.periodo?.contem(dia) ?? false)) {
      _safraSelecionada = null;
    }
  }

  void _limparDataFim() {
    _dataFim = null;
    _dataFimController.clear();
  }

  void _ajustarDataFimAoEscopo() {
    if (_dataFim == null) return;

    final teto = _tetoDataFim(_talhaoDoLancamento(), _safraDoLancamento());

    if (!_aceitaDataFim ||
        _dataFim!.isBefore(_dataInicio!) ||
        _dataFim!.isAfter(teto)) {
      _limparDataFim();
    }
  }

  Future<void> _selecionarDataFim() async {
    final escolhida = await selecionarData(
      context: context,
      ajuda: widget.ajudaDataFim,
      inicial: _dataFim ?? _dataInicio,
      minima: _dataInicio,
      maxima: _tetoDataFim(_talhaoDoLancamento(), _safraDoLancamento()),
    );

    if (escolhida == null || !mounted) return;

    setState(() {
      _dataFim = escolhida;
      _dataFimController.text = formatarDataBr(escolhida);
    });
  }

  void _aoSelecionarTalhao(Talhao? talhao) {
    setState(() {
      _talhaoSelecionado = talhao;
      _ajustarDataFimAoEscopo();
    });
  }

  void _aoSelecionarSafra(Safra? safra) {
    setState(() {
      _safraSelecionada = safra;
      _ajustarDataFimAoEscopo();
    });
  }

  Future<void> _abrirSelecaoResponsaveis() async {
    final escolhidos = await mostrarSelecaoResponsaveis(
      context: context,
      viewModel: _viewModel,
      selecionadosAtuais: _responsaveisSelecionados,
    );

    if (escolhidos == null || !mounted) return;

    setState(() => _responsaveisSelecionados = escolhidos);
  }

  Future<void> _abrirCadastroTransacao() async {
    final idPropriedade =
        context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarAviso(
        context,
        'Selecione uma propriedade antes de lançar uma despesa.',
      );
      return;
    }

    final despesa = await mostrarCadastroTransacao(
      context: context,
      idPropriedade: idPropriedade,
      catalogoDePessoas: _viewModel,
      responsaveis: _responsaveisSelecionados,
    );

    if (despesa == null || !mounted) return;

    setState(() => _despesas = [..._despesas, despesa]);
  }

  Future<void> _abrirDetalhesDespesa(Despesa despesa) async {
    final excluir = await mostrarDetalhesDespesa(
      context: context,
      despesa: despesa,
    );

    if (!excluir || !mounted) return;

    _removerDespesa(despesa);
  }

  void _removerDespesa(Despesa despesa) {
    setState(() {
      _despesas =
          _despesas.where((atual) => !identical(atual, despesa)).toList();
    });
  }

  Future<void> _confirmarSaida() async {
    final editando = widget.valoresIniciais != null;

    final descartar = await confirmarDescarte(
      context,
      titulo: editando ? 'Descartar alterações?' : 'Descartar cadastro?',
      mensagem: editando
          ? 'As alterações feitas serão perdidas.'
          : 'Os dados preenchidos serão perdidos.',
    );

    if (descartar && mounted) Navigator.of(context).pop();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.validarCamposEspecificos?.call() == false) return;

    if (_dataInicio == null) {
      mostrarAviso(context, 'Selecione a data de início.');
      return;
    }

    final talhao = _talhaoDoLancamento();

    if (talhao?.id == null) {
      mostrarAviso(context, 'Selecione o talhão do lançamento.');
      return;
    }

    final safra = _safraDoLancamento();

    if (safra?.id == null) {
      mostrarAviso(context, 'Selecione a safra do lançamento.');
      return;
    }

    if (_dataFimObrigatoria(talhao, safra) && _dataFim == null) {
      mostrarAviso(
        context,
        'Informe a data de término: o talhão ou a safra deste lançamento já foi encerrado.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final sucesso = await widget.aoSalvar(
      DadosFormularioAtividade(
        idTalhao: talhao!.id!,
        idSafra: safra!.id!,
        dataInicio: _dataInicio!,
        dataFim: _dataFim,
        descricao: _descricaoController.text,
        responsaveis: _responsaveisSelecionados,
        despesas: _despesas,
      ),
    );

    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(
        context,
        _viewModel.mensagemErro ?? 'Erro desconhecido ao salvar a atividade.',
      );
      return;
    }

    _salvou = true;

    mostrarSucesso(context, widget.mensagemSucesso);
    Navigator.of(context).pop(true);
  }

  void _conferirDataInicial(bool carregando) {
    if (_conferiuDataInicial || carregando || _janelas.isEmpty) return;

    _conferiuDataInicial = true;

    if (_dataInicio == null || _aceitaDia(_dataInicio!)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _dataInicio = null;
        _dataInicioController.clear();
        _talhaoSelecionado = null;
        _safraSelecionada = null;
        _limparDataFim();
      });

      mostrarAviso(
        context,
        'O dia escolhido não tem talhão e safra abertos ao mesmo tempo. Selecione outra data de início.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final safraViewModel = context.watch<SafraViewModel>();
    final idPropriedade =
        context.watch<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    if (idPropriedade != null &&
        (idPropriedade != safraViewModel.propriedadeIdAtual ||
            !safraViewModel.dadosCarregados)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        safraViewModel.carregarDadosDaPropriedade(idPropriedade);
      });
    }

    return PopScope(
      canPop: _salvou || !_temAlteracoes,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmarSaida();
      },
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(titulo: widget.titulo),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            _janelas = _calcularJanelas(
              _viewModel.talhoes,
              safraViewModel.safras,
            );

            _semearEscopo(_viewModel.talhoes, safraViewModel.safras);

            final carregando =
                _viewModel.isCarregandoDados || safraViewModel.isLoading;

            _conferirDataInicial(carregando);

            return CorpoComEstado(
              isLoading: carregando,
              mensagemErro: null,
              vazio: _janelas.isEmpty,
              construirVazio: (_) => _construirEstadoVazio(safraViewModel),
              construirConteudo: (_) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _construirFormulario(safraViewModel),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirEstadoVazio(SafraViewModel safraViewModel) {
    final semTalhoes =
        _viewModel.talhoes.where((talhao) => talhao.id != null).isEmpty;

    final semSafras = safraViewModel.safras
        .where((safra) => safra.id != null && safra.periodo != null)
        .isEmpty;

    final mensagem = _viewModel.mensagemErro ??
        (semTalhoes
            ? widget.mensagemSemTalhoes
            : semSafras
                ? widget.mensagemSemSafras
                : widget.mensagemSemJanela);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco_outlined, size: 56, color: AppCores.verdeSecundario),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: CustomButton(
                text: 'Tentar novamente',
                onPressed: _recarregarDados,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCampoDeEscopo<T>({
    required String rotulo,
    required List<T> disponiveis,
    required T? selecionado,
    required String Function(T item) rotuloItem,
    required String dicaSelecionar,
    required ValueChanged<T?> aoSelecionar,
  }) {
    final semData = _dataInicio == null;

    if (!semData && disponiveis.length == 1) {
      return _CampoFixoAtividade(
        rotulo: rotulo,
        valor: rotuloItem(disponiveis.first),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(rotulo),
        DropdownButtonFormField<T>(
          key: ValueKey('$rotulo-$_dataInicio'),
          initialValue: selecionado,
          isExpanded: true,
          decoration: decoracaoDeSeletor(),
          hint: Text(
            semData ? 'Escolha a data de início primeiro' : dicaSelecionar,
            style: const TextStyle(color: Colors.black26, fontSize: 14),
          ),
          items: disponiveis.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(rotuloItem(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: semData ? null : aoSelecionar,
          validator: (valor) => valor == null ? 'Obrigatório' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _construirFormulario(SafraViewModel safraViewModel) {
    final talhoesDisponiveis = _talhoesDisponiveis();
    final safrasDisponiveis = _safrasDisponiveis(safraViewModel);

    final talhaoDoLancamento = _resolverTalhao(talhoesDisponiveis);
    final safraDoLancamento = _resolverSafra(safrasDisponiveis);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoDeData(
              label: 'Data de início',
              controller: _dataInicioController,
              aoTocar: _selecionarDataInicio,
            ),

            _construirCampoDeEscopo<Talhao>(
              rotulo: 'Talhão',
              disponiveis: talhoesDisponiveis,
              selecionado: talhaoDoLancamento,
              rotuloItem: (talhao) => talhao.nomeExibicao,
              dicaSelecionar: 'Selecione o talhão',
              aoSelecionar: _aoSelecionarTalhao,
            ),

            _construirCampoDeEscopo<Safra>(
              rotulo: 'Safra',
              disponiveis: safrasDisponiveis,
              selecionado: safraDoLancamento,
              rotuloItem: (safra) => safra.nomeExibicao,
              dicaSelecionar: 'Selecione a safra',
              aoSelecionar: _aoSelecionarSafra,
            ),

            if (widget.construirCamposEspecificos != null) ...[
              widget.construirCamposEspecificos!(context),
              const SizedBox(height: 16),
            ],

            if (_aceitaDataFim) ...[
              CampoDeData(
                label: _dataFimObrigatoria(talhaoDoLancamento, safraDoLancamento)
                    ? 'Data de término'
                    : 'Data de término (opcional)',
                controller: _dataFimController,
                aoTocar: _selecionarDataFim,
                hintText: widget.dicaDataFim,
                obrigatorio: false,
              ),
              if (_dataFimObrigatoria(talhaoDoLancamento, safraDoLancamento))
                const _AvisoEscopoEncerrado()
              else if (_dataFim != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(_limparDataFim),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Remover data de término'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppCores.verdePrimario),
                  ),
                ),
            ] else if (_dataInicio != null)
              const _AvisoAgendamento(),

            const SizedBox(height: 8),

            CustomTextField(
              label: 'Descrição (opcional)',
              controller: _descricaoController,
              hintText: 'O que foi feito no talhão',
            ),

            const Divider(),
            const SizedBox(height: 16),

            rotuloDeCampo('Responsáveis'),
            SeletorMultiploAtividade<Pessoa>(
              icone: Icons.group_outlined,
              rotuloVazio: 'Selecionar responsáveis',
              selecionados: _responsaveisSelecionados,
              rotuloItem: (pessoa) => pessoa.nomeParaExibicao,
              rotuloContagem: _responsaveisSelecionados.contagem,
              aoAbrir: _abrirSelecaoResponsaveis,
              aoRemover: (pessoa) => setState(() {
                _responsaveisSelecionados = _responsaveisSelecionados
                    .where((atual) => atual.id != pessoa.id)
                    .toList();
              }),
            ),

            if (widget.construirCamposFinais != null) ...[
              const SizedBox(height: 24),
              widget.construirCamposFinais!(context),
            ],

            const SizedBox(height: 24),
            rotuloDeCampo('Despesas'),
            SeletorMultiploAtividade<Despesa>(
              icone: Icons.payments_outlined,
              rotuloVazio: 'Adicionar despesa',
              selecionados: _despesas,
              rotuloItem: (despesa) => despesa.resumoComBeneficiado,
              rotuloContagem: _despesas.contagemComTotal,
              aoAbrir: _abrirCadastroTransacao,
              aoRemover: _removerDespesa,
              aoTocarItem: _abrirDetalhesDespesa,
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: _viewModel.isLoading
                  ? 'Salvando...'
                  : widget.rotuloBotaoSalvar,
              onPressed: _viewModel.isLoading ? null : _salvar,
            ),
          ],
        ),
      ),
    );
  }

  DateTime? get _primeiroDiaLancavel =>
      _janelas.isEmpty ? null : _janelas.first.inicio;

  DateTime? get _ultimoDiaLancavel =>
      _janelas.isEmpty ? null : _janelas.last.fim;

  bool _aceitaDia(DateTime dia) =>
      _janelas.any((periodo) => periodo.contem(dia));

  static List<Periodo> _calcularJanelas(
    List<Talhao> talhoes,
    List<Safra> safras,
  ) {
    final periodosDeTalhao = talhoes
        .where((talhao) => talhao.id != null)
        .map((talhao) => talhao.periodo)
        .toList();

    final periodosDeSafra = safras
        .where((safra) => safra.id != null)
        .map((safra) => safra.periodo)
        .whereType<Periodo>()
        .toList();

    final coexistencias = <Periodo>[];

    for (final talhao in periodosDeTalhao) {
      for (final safra in periodosDeSafra) {
        final coexistencia = talhao.intersecao(safra);

        if (coexistencia != null) coexistencias.add(coexistencia);
      }
    }

    return _unirJanelas(coexistencias);
  }

  DateTime? _diaValidoMaisProximo(DateTime referencia) {
    if (_janelas.isEmpty) return null;

    final dia = apenasData(referencia);

    if (_aceitaDia(dia)) return dia;

    DateTime? anterior;
    DateTime? posterior;

    for (final periodo in _janelas) {
      if (periodo.inicio.isAfter(dia)) {
        posterior = periodo.inicio;
        break;
      }

      anterior = periodo.fim;
    }

    if (anterior == null) return posterior;
    if (posterior == null) return anterior;

    return dia.difference(anterior) <= posterior.difference(dia)
        ? anterior
        : posterior;
  }

  static List<Periodo> _unirJanelas(List<Periodo> coexistencias) {
    if (coexistencias.isEmpty) return const [];

    final ordenados = List<Periodo>.from(coexistencias)
      ..sort((a, b) => a.inicio.compareTo(b.inicio));

    final unidos = <Periodo>[ordenados.first];

    for (final atual in ordenados.skip(1)) {
      final anterior = unidos.last;

      if (anterior.emAberto) continue;

      final encostam = !atual.inicio.isAfter(diaSeguinte(anterior.fim!));

      if (encostam) {
        unidos[unidos.length - 1] = Periodo(
          inicio: anterior.inicio,
          fim: maiorData(anterior.fim, atual.fim),
        );
        continue;
      }

      unidos.add(atual);
    }

    return List.unmodifiable(unidos);
  }
}

class _AvisoAgendamento extends StatelessWidget {
  const _AvisoAgendamento();

  @override
  Widget build(BuildContext context) {
    return const _CaixaAvisoAtividade(
      icone: Icons.event_available,
      texto: 'Atividade agendada. A data de término é informada na '
          'confirmação, depois que ela começar.',
    );
  }
}

class _AvisoEscopoEncerrado extends StatelessWidget {
  const _AvisoEscopoEncerrado();

  @override
  Widget build(BuildContext context) {
    return const _CaixaAvisoAtividade(
      icone: Icons.event_busy,
      texto: 'O talhão ou a safra deste lançamento já foi encerrado: informe '
          'a data de término, que não pode passar desse encerramento.',
    );
  }
}

class _CaixaAvisoAtividade extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _CaixaAvisoAtividade({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppCores.verdeSecundario.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: AppCores.verdePrimario),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoFixoAtividade extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _CampoFixoAtividade({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(rotulo),
        InputDecorator(
          decoration: decoracaoDeSeletor().copyWith(
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
          child: Text(
            valor,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
