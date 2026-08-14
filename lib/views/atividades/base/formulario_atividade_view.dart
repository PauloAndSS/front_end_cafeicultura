import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/dados_formulario_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/cadastrar_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/selecionar_responsaveis_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_data_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:provider/provider.dart';

const _verdePrimario = Color(0xFF67835C);
const _verdeSecundario = Color(0xFF8FA67E);
const _cinzaBorda = Color(0xFFE0E0E0);
const _vermelhoErro = Color(0xFFD32F2F);

/// Formulário de cadastro de uma atividade agrícola.
///
/// Talhão, datas, descrição e responsáveis são iguais em toda atividade; o que
/// muda entra pelos slots de campo específico — [construirCamposEspecificos]
/// logo abaixo do talhão e [construirCamposFinais] depois dos responsáveis.
///
/// [construirCamposEspecificos] é um **builder**, não um `Widget` pronto: o
/// `ListenableBuilder` do ViewModel vive aqui dentro, então um widget montado
/// pela tela concreta congelaria no estado do ViewModel naquele frame — na
/// prática, um dropdown de catálogo eternamente vazio, porque a lista só chega
/// depois do `await`.
class FormularioAtividadeView extends StatefulWidget {
  final CadastrarAtividadeViewModel viewModel;

  /// Dia escolhido no calendário, quando o cadastro veio de lá: entra no campo
  /// de data de início já preenchido, e continua editável.
  final DateTime? dataInicial;

  final String titulo;
  final String rotuloBotaoSalvar;
  final String mensagemSucesso;

  /// 'Data de início do trato cultural' — cabeçalho do calendário.
  final String ajudaDataInicio;
  final String ajudaDataFim;

  /// 'Trato em andamento' — placeholder do campo de data de término.
  final String dicaDataFim;

  /// Frase do estado vazio quando a propriedade não tem talhão ativo.
  final String mensagemSemTalhoes;

  /// Campos do tipo concreto, logo abaixo do talhão.
  final WidgetBuilder? construirCamposEspecificos;

  /// Campos do tipo concreto que ficam no fim do formulário, depois dos
  /// responsáveis — os insumos do trato cultural, por exemplo.
  final WidgetBuilder? construirCamposFinais;

  /// Validação do que não é `FormField` — os `validator` do [Form] já rodam
  /// sozinhos. Devolver `false` cancela o salvamento.
  final bool Function()? validarCamposEspecificos;

  /// Entra na confirmação de saída: sem isto, sair com apenas o campo
  /// específico preenchido não pediria confirmação.
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
    required this.aoSalvar,
    this.dataInicial,
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

  int? _idTalhaoSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  List<Pessoa> _responsaveisSelecionados = [];

  /// Libera o `pop` depois de salvar: sem isto o usuário confirmaria um
  /// "descartar cadastro?" logo após o cadastro ter dado certo.
  bool _salvou = false;

  CadastrarAtividadeViewModel get _viewModel => widget.viewModel;

  /// Espelha se a descrição tem texto. Sem isto o `canPop` do [PopScope], que
  /// é calculado no `build`, não enxergaria a digitação: sair com só a
  /// descrição preenchida descartaria o formulário sem avisar.
  bool _descricaoPreenchida = false;

  @override
  void initState() {
    super.initState();

    _descricaoController.addListener(_aoDigitarDescricao);

    if (widget.dataInicial != null) {
      _dataInicio = widget.dataInicial;
      _dataInicioController.text = formatarDataBr(widget.dataInicial!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.init(context.read<PropriedadesUsuarioViewModel>());
      }
    });
  }

  /// Só reconstrói na transição vazio ↔ preenchido, não a cada tecla.
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

  /// A data compara com [FormularioAtividadeView.dataInicial], e não com nulo:
  /// o formulário aberto pelo calendário já nasce com ela preenchida, e voltar
  /// sem ter tocado em nada pediria confirmação de descarte à toa.
  bool get _temAlteracoes =>
      _idTalhaoSelecionado != null ||
      _dataInicio != widget.dataInicial ||
      _descricaoPreenchida ||
      _responsaveisSelecionados.isNotEmpty ||
      widget.camposEspecificosPreenchidos;

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: _vermelhoErro),
    );
  }

  /// Data de término só existe em lançamento retroativo: o que ainda vai
  /// acontecer não tem como já ter terminado. Início hoje entra aqui — a
  /// atividade de um dia só, feita e fechada no mesmo dia.
  bool get _aceitaDataFim => _dataInicio != null && !ehFutura(_dataInicio!);

  Future<void> _selecionarDataInicio() async {
    final escolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: _dataInicio,
      maxima: limiteAgendamento,
    );

    if (escolhida == null) return;

    setState(() {
      _dataInicio = escolhida;
      _dataInicioController.text = formatarDataBr(escolhida);

      // Um término anterior ao novo início deixaria de fazer sentido, e um
      // início no futuro faz o campo de término sumir — em qualquer dos dois
      // casos o que já estava escolhido precisa cair junto.
      if (_dataFim != null && (_dataFim!.isBefore(escolhida) || !_aceitaDataFim)) {
        _limparDataFim();
      }
    });
  }

  /// Só chamado de dentro de um `setState` ou de um `onPressed` que já
  /// reconstrói — o campo em si é `readOnly`, quem guarda o valor é [_dataFim].
  void _limparDataFim() {
    _dataFim = null;
    _dataFimController.clear();
  }

  Future<void> _selecionarDataFim() async {
    // O campo não é montado sem data de início, então não há guarda a fazer.
    final escolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataFim,
      inicial: _dataFim ?? _dataInicio,
      minima: _dataInicio,
    );

    if (escolhida == null) return;

    setState(() {
      _dataFim = escolhida;
      _dataFimController.text = formatarDataBr(escolhida);
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

  Future<void> _confirmarSaida() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar cadastro?'),
        content: const Text(
          'Os dados preenchidos serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continuar editando',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Descartar',
              style: TextStyle(
                color: _vermelhoErro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (descartar == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.validarCamposEspecificos?.call() == false) return;

    if (_dataInicio == null) {
      _mostrarAviso('Selecione a data de início.');
      return;
    }

    FocusScope.of(context).unfocus();

    final sucesso = await widget.aoSalvar(
      DadosFormularioAtividade(
        idTalhao: _idTalhaoSelecionado!,
        dataInicio: _dataInicio!,
        dataFim: _dataFim,
        descricao: _descricaoController.text,
        responsaveis: _responsaveisSelecionados,
      ),
    );

    if (!mounted) return;

    if (!sucesso) {
      _mostrarAviso(
        _viewModel.mensagemErro ?? 'Erro desconhecido ao salvar a atividade.',
      );
      return;
    }

    _salvou = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.mensagemSucesso),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _salvou || !_temAlteracoes,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmarSaida();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            widget.titulo,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _verdePrimario,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return CorpoComEstado(
              isLoading: _viewModel.isCarregandoDados,
              // O erro do formulário aparece no estado vazio junto da frase de
              // "cadastre um talhão": as duas situações levam à mesma saída.
              mensagemErro: null,
              vazio: _viewModel.talhoesAtivos.isEmpty,
              construirVazio: (_) => _construirEstadoVazio(),
              construirConteudo: (_) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _construirFormulario(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirEstadoVazio() {
    final mensagem = _viewModel.mensagemErro ?? widget.mensagemSemTalhoes;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco_outlined, size: 56, color: _verdeSecundario),
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
                onPressed: () => _viewModel.init(
                  context.read<PropriedadesUsuarioViewModel>(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFormulario() {
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
            construirRotuloAtividade('Talhão'),
            DropdownButtonFormField<int>(
              initialValue: _idTalhaoSelecionado,
              isExpanded: true,
              decoration: decoracaoSeletorAtividade(),
              hint: const Text(
                'Selecione o talhão',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              items: _viewModel.talhoesAtivos.map((talhao) {
                return DropdownMenuItem(
                  value: talhao.id,
                  child: Text(
                    talhao.nomeExibicao,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (valor) =>
                  setState(() => _idTalhaoSelecionado = valor),
              validator: (valor) => valor == null ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),

            if (widget.construirCamposEspecificos != null) ...[
              widget.construirCamposEspecificos!(context),
              const SizedBox(height: 16),
            ],

            GestureDetector(
              onTap: _selecionarDataInicio,
              child: AbsorbPointer(
                child: CustomTextField(
                  label: 'Data de início',
                  controller: _dataInicioController,
                  hintText: 'Selecione a data',
                  readOnly: true,
                  validator: (valor) =>
                      valor == null || valor.isEmpty ? 'Obrigatório' : null,
                ),
              ),
            ),

            if (_aceitaDataFim) ...[
              GestureDetector(
                onTap: _selecionarDataFim,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Data de término (opcional)',
                    controller: _dataFimController,
                    hintText: widget.dicaDataFim,
                    readOnly: true,
                  ),
                ),
              ),
              if (_dataFim != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(_limparDataFim),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Remover data de término'),
                    style: TextButton.styleFrom(foregroundColor: _verdePrimario),
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

            construirRotuloAtividade('Responsáveis'),
            SeletorMultiploAtividade<Pessoa>(
              icone: Icons.group_outlined,
              rotuloVazio: 'Selecionar responsáveis',
              selecionados: _responsaveisSelecionados,
              rotuloItem: (pessoa) => pessoa.nomeParaExibicao,
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
}

/// Explica o sumiço do campo de término quando a data de início é futura.
///
/// Sem isto o campo simplesmente desaparece ao escolher uma data futura, e o
/// usuário fica sem saber se a tela quebrou.
class _AvisoAgendamento extends StatelessWidget {
  const _AvisoAgendamento();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _verdeSecundario.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available, size: 20, color: _verdePrimario),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Atividade agendada. A data de término é informada na '
              'confirmação, depois que ela começar.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rótulo acima de um campo do formulário de atividade.
///
/// Público para a tela concreta rotular os campos específicos dela com o mesmo
/// estilo dos comuns.
Widget construirRotuloAtividade(String texto) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}

/// Moldura dos dropdowns do formulário de atividade.
InputDecoration decoracaoSeletorAtividade() {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _cinzaBorda),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _cinzaBorda),
    ),
  );
}
