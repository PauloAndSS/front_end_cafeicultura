import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/atividades/widgets/selecionar_responsaveis_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/atividades/widgets/seletor_data_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);
const _vermelhoErro = Color(0xFFD32F2F);

/// Blocos que só um tipo de atividade tem.
///
/// Recebe o `editavel` já calculado pela base para a regra de bloqueio não
/// divergir entre a parte comum e a específica.
typedef ConstrutorBlocosAtividade<T> = List<Widget> Function(
  BuildContext context,
  T atividade,
  bool editavel,
);

/// Detalhes de uma atividade agrícola.
///
/// Descrição e responsáveis são editados tocando no próprio atributo dentro do
/// cartão — o lápis marca quais têm endpoint de alteração, e ele só aparece se
/// o ViewModel expuser a chamada correspondente. Finalizar continua sendo
/// botão: muda o estado da atividade inteira e é irreversível.
///
/// Recebe o [nomeTalhao] pronto porque a listagem já resolveu o nome a partir
/// do `idTalhao` — refazer a busca aqui repetiria dezenas de requisições por
/// uma string que o chamador já tem.
class DetalhesAtividadeView<T extends EventoAgricola>
    extends StatefulWidget {
  final DetalhesAtividadeViewModel<T> viewModel;
  final String nomeTalhao;

  /// 'Informações do Trato' — cabeçalho do cartão.
  final String tituloCartao;

  final String rotuloBotaoFinalizar;
  final String tituloDialogoFinalizar;

  /// 'Data de término do trato cultural' — cabeçalho do calendário.
  final String ajudaDataFim;

  final String mensagemSucessoFinalizar;
  final String mensagemJaFinalizada;

  /// Linhas de info do tipo concreto, logo após 'Talhão:'.
  final ConstrutorBlocosAtividade<T>? construirLinhasExtras;

  /// Seções do tipo concreto, depois de 'Responsáveis'.
  final ConstrutorBlocosAtividade<T>? construirSecoesExtras;

  const DetalhesAtividadeView({
    super.key,
    required this.viewModel,
    required this.nomeTalhao,
    required this.tituloCartao,
    required this.rotuloBotaoFinalizar,
    required this.tituloDialogoFinalizar,
    required this.ajudaDataFim,
    required this.mensagemSucessoFinalizar,
    required this.mensagemJaFinalizada,
    this.construirLinhasExtras,
    this.construirSecoesExtras,
  });

  @override
  State<DetalhesAtividadeView<T>> createState() =>
      _DetalhesAtividadeViewState<T>();
}

class _DetalhesAtividadeViewState<T extends EventoAgricola>
    extends State<DetalhesAtividadeView<T>> {
  DetalhesAtividadeViewModel<T> get _viewModel => widget.viewModel;

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.green),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: _vermelhoErro),
    );
  }

  Future<void> _finalizar() async {
    final atividade = _viewModel.atividade;

    final dataEscolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataFim,
      minima: atividade.dataInicio,
    );

    if (dataEscolhida == null || !mounted) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.tituloDialogoFinalizar),
        content: Text(
          'Deseja finalizar "${atividade.tituloExibicao}" na data '
          '${formatarDataBr(dataEscolhida)}?\n\n'
          'Depois de finalizada ela não poderá mais ser alterada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Finalizar',
              style: TextStyle(
                color: _verdePrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    final sucesso = await _viewModel.finalizar(dataEscolhida);

    if (!mounted) return;

    if (sucesso) {
      _mostrarSucesso(widget.mensagemSucessoFinalizar);
    } else {
      _mostrarErro(_viewModel.mensagemErro ?? 'Erro ao finalizar a atividade.');
    }
  }

  Future<void> _alterarDescricao() async {
    final novaDescricao = await showDialog<String>(
      context: context,
      builder: (_) => _AlterarDescricaoDialog(
        descricaoAtual: _viewModel.atividade.descricao ?? '',
      ),
    );

    if (novaDescricao == null || !mounted) return;

    final sucesso = await _viewModel.alterarDescricao(novaDescricao);

    if (!mounted) return;

    if (sucesso) {
      _mostrarSucesso('Descrição alterada com sucesso!');
    } else {
      _mostrarErro(_viewModel.mensagemErro ?? 'Erro ao alterar a descrição.');
    }
  }

  Future<void> _editarResponsaveis() async {
    final escolhidos = await mostrarSelecaoResponsaveis(
      context: context,
      viewModel: _viewModel,
      selecionadosAtuais: _viewModel.atividade.responsaveis,
    );

    if (escolhidos == null || !mounted) return;

    final sucesso = await _viewModel.alterarResponsaveis(escolhidos);

    if (!mounted) return;

    if (sucesso) {
      _mostrarSucesso('Responsáveis atualizados com sucesso!');
    } else {
      _mostrarErro(
        _viewModel.mensagemErro ?? 'Erro ao alterar os responsáveis.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_viewModel.houveAlteracao);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Text(
              _viewModel.atividade.tituloExibicao,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: _verdePrimario,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirCartaoInformacoes(context),
                  const SizedBox(height: 32),
                  if (_viewModel.atividade.emAndamento)
                    _construirAcoes()
                  else
                    AvisoAtividadeFinalizada(
                      mensagem: widget.mensagemJaFinalizada,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirCartaoInformacoes(BuildContext context) {
    final atividade = _viewModel.atividade;

    // Atividade finalizada congela tudo; durante uma requisição em voo, o toque
    // não pode disparar uma segunda. O lápis e o InkWell nascem os dois deste
    // mesmo null, então nunca aparece um indicador que não responde.
    final editavel = atividade.emAndamento && !_viewModel.isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // O Container branco não é um Material: sem esta camada transparente o
      // splash do InkWell pintaria no Material do Scaffold, atrás do cartão —
      // ou seja, invisível.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.tituloCartao,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _verdePrimario,
                  ),
                ),
                BadgeStatusAtividade(atividade: atividade),
              ],
            ),
            const Divider(height: 24, color: _cinzaBorda),
            ...?widget.construirLinhasExtras?.call(
              context,
              atividade,
              editavel,
            ),
            LinhaInfoAtividade(rotulo: 'Talhão:', valor: widget.nomeTalhao),
            LinhaInfoAtividade(
              rotulo: 'Descrição:',
              valor: atividade.descricaoTexto,
              onEditar: editavel && _viewModel.podeAlterarDescricao
                  ? _alterarDescricao
                  : null,
            ),
            LinhaInfoAtividade(
              rotulo: 'Data de Início:',
              valor: atividade.dataInicioFormatada,
            ),
            LinhaInfoAtividade(
              rotulo: 'Data de Término:',
              valor: atividade.dataFimFormatada ?? 'Em aberto',
            ),
            if (atividade.dataCadastroFormatada != null)
              LinhaInfoAtividade(
                rotulo: 'Cadastrado em:',
                valor: atividade.dataCadastroFormatada!,
              ),
            const Divider(height: 32, color: _cinzaBorda),
            SecaoEditavelAtividade(
              titulo: 'Responsáveis',
              conteudo: ChipsAtividade(
                rotulos: atividade.responsaveis
                    .map((pessoa) => pessoa.nomeParaExibicao)
                    .toList(),
                textoVazio: 'Nenhum responsável',
              ),
              onEditar: editavel && _viewModel.podeAlterarResponsaveis
                  ? _editarResponsaveis
                  : null,
            ),
            ...?widget.construirSecoesExtras?.call(
              context,
              atividade,
              editavel,
            ),
          ],
        ),
      ),
    );
  }

  /// Só finalizar sobrou como botão: as edições de atributo migraram para o
  /// próprio cartão, mas finalizar congela a atividade e não pode ficar a um
  /// toque distraído de distância.
  Widget _construirAcoes() {
    if (!_viewModel.podeFinalizar) return const SizedBox.shrink();

    final bloqueado = _viewModel.isLoading;

    return CustomButton(
      text: bloqueado ? 'Aguarde...' : widget.rotuloBotaoFinalizar,
      onPressed: bloqueado ? null : _finalizar,
    );
  }
}

/// Diálogo de edição da descrição.
///
/// É um `StatefulWidget` para o controller morrer no `dispose` do elemento: o
/// future de `showDialog` completa no `pop`, **antes** da animação de saída
/// (ver `Route.didComplete`), então descartá-lo logo após o `await` atinge um
/// `TextField` ainda montado e quebra a desmontagem da subárvore.
class _AlterarDescricaoDialog extends StatefulWidget {
  final String descricaoAtual;

  const _AlterarDescricaoDialog({required this.descricaoAtual});

  @override
  State<_AlterarDescricaoDialog> createState() =>
      _AlterarDescricaoDialogState();
}

class _AlterarDescricaoDialogState extends State<_AlterarDescricaoDialog> {
  late final _controller = TextEditingController(text: widget.descricaoAtual);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar Descrição'),
      // Sem `Form`: a descrição é opcional, então salvar em branco é uma ação
      // válida — é assim que se apaga a descrição de uma atividade.
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'O que foi feito no talhão',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _cinzaBorda),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text(
            'Salvar',
            style: TextStyle(color: _verdePrimario, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
