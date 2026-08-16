import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/confirmar_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/selecionar_responsaveis_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_data_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
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
/// Data de início, descrição e responsáveis são editados tocando no próprio
/// atributo dentro do cartão — o lápis marca quais têm endpoint de alteração, e
/// ele só aparece se o ViewModel expuser a chamada correspondente. Confirmar
/// continua sendo botão: muda o estado da atividade inteira e é irreversível.
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

  /// 'Confirmar Trato' — rótulo do botão que abre a tela de confirmação.
  final String rotuloBotaoConfirmar;

  /// 'Confirmar Trato Cultural' — título da tela de confirmação.
  final String tituloTelaConfirmar;

  /// 'Data de início do trato cultural' — cabeçalhos dos calendários.
  final String ajudaDataInicio;
  final String ajudaDataFim;

  final String mensagemSucessoConfirmar;
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
    required this.rotuloBotaoConfirmar,
    required this.tituloTelaConfirmar,
    required this.ajudaDataInicio,
    required this.ajudaDataFim,
    required this.mensagemSucessoConfirmar,
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

  /// A confirmação é tela, e não diálogo: são dois calendários que dependem um
  /// do outro. O erro é reportado lá dentro, para o usuário poder corrigir as
  /// datas sem refazer o caminho — aqui só chega o sucesso.
  Future<void> _abrirConfirmacao() async {
    final confirmou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmarAtividadeView<T>(
          viewModel: _viewModel,
          nomeTalhao: widget.nomeTalhao,
          titulo: widget.tituloTelaConfirmar,
          ajudaDataInicio: widget.ajudaDataInicio,
          ajudaDataFim: widget.ajudaDataFim,
        ),
      ),
    );

    if (confirmou == true && mounted) {
      _mostrarSucesso(widget.mensagemSucessoConfirmar);
    }
  }

  /// Corrigir o início não exige confirmar a atividade — é edição de atributo,
  /// como a descrição.
  ///
  /// O teto é [limiteAgendamento], e não hoje: quem marcou para o dia errado
  /// precisa poder adiar. A atividade então volta para "Agendada" sozinha,
  /// porque o status sai das datas.
  Future<void> _alterarDataInicio() async {
    // `apenasData` porque a data vem do backend em meia-noite UTC: crua, o
    // picker abriria no dia anterior no fuso de Brasília.
    final atual = apenasData(_viewModel.atividade.dataInicio);

    final escolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: atual,
      maxima: limiteAgendamento,
    );

    if (escolhida == null || !mounted) return;
    if (apenasData(escolhida) == atual) return;

    final sucesso = await _viewModel.alterarDataInicio(escolhida);

    if (!mounted) return;

    if (sucesso) {
      _mostrarSucesso('Data de início alterada com sucesso!');
    } else {
      _mostrarErro(
        _viewModel.mensagemErro ?? 'Erro ao alterar a data de início.',
      );
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

  /// Chamado pelo [BotaoExcluir] depois que o usuário confirma no diálogo.
  ///
  /// Se o backend recusar, a tela **fica aberta** com o motivo no SnackBar: a
  /// recusa costuma ser condicional (vínculo com outro cadastro, safra
  /// fechada), e fechar a tela esconderia do usuário o que ele precisa resolver.
  Future<void> _excluir() async {
    final sucesso = await _viewModel.excluir();

    if (!mounted) return;

    if (!sucesso) {
      _mostrarErro(_viewModel.mensagemErro ?? 'Erro ao excluir a atividade.');
      return;
    }

    _mostrarSucesso('Atividade excluída com sucesso!');

    // `Navigator.pop` direto: o `PopScope` abaixo intercepta apenas o caminho
    // do botão voltar (`maybePop`), e o valor que ele devolveria
    // (`houveAlteracao`) já é `true` depois da exclusão. Não há divergência.
    Navigator.of(context).pop(true);
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
                  _construirRodape(),
                  _construirAcaoExcluir(),
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
    //
    // `!finalizado`, e não `emAndamento`: atividade agendada ainda não começou,
    // mas descrição, responsáveis e insumos continuam editáveis.
    final editavel = !atividade.finalizado && !_viewModel.isLoading;

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
              onEditar: editavel && _viewModel.podeAlterarDataInicio
                  ? _alterarDataInicio
                  : null,
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

  /// Um ramo por estado da atividade.
  ///
  /// Só confirmar sobrou como botão: as edições de atributo migraram para o
  /// próprio cartão, mas confirmar congela a atividade e não pode ficar a um
  /// toque distraído de distância. Agendada não tem o que confirmar — ela nem
  /// começou —, e o aviso diz a partir de quando terá.
  Widget _construirRodape() {
    final atividade = _viewModel.atividade;

    return switch (atividade.status) {
      StatusEvento.agendado => AvisoAtividadeAgendada(
          dataInicioFormatada: atividade.dataInicioFormatada,
        ),
      StatusEvento.finalizado => AvisoAtividadeFinalizada(
          mensagem: widget.mensagemJaFinalizada,
        ),
      StatusEvento.emAndamento => _construirBotaoConfirmar(),
    };
  }

  Widget _construirBotaoConfirmar() {
    if (!_viewModel.podeConfirmar) return const SizedBox.shrink();

    final bloqueado = _viewModel.isLoading;

    return CustomButton(
      text: bloqueado ? 'Aguarde...' : widget.rotuloBotaoConfirmar,
      onPressed: bloqueado ? null : _abrirConfirmacao,
    );
  }

  /// Discreto de propósito, e abaixo do rodapé: excluir é irreversível e não é
  /// o que o usuário veio fazer aqui. A ação primária do estado — confirmar —
  /// continua sendo a que tem peso visual.
  ///
  /// Fica fora do `switch` de [_construirRodape] porque aquele switch é
  /// exaustivo nos três status e a exclusão vale em dois: enfiá-la lá obrigaria
  /// a repetir o botão em dois ramos. Quem decide se aparece é [podeExcluir],
  /// para a regra de "agendada e em andamento" não ficar escrita nos dois lados.
  Widget _construirAcaoExcluir() {
    if (!_viewModel.podeExcluir) return const SizedBox.shrink();

    return BotaoExcluir(
      titulo: 'Excluir atividade?',
      mensagem:
          'Deseja realmente excluir "${_viewModel.atividade.tituloExibicao}"? '
          'Esta ação não poderá ser desfeita.',
      bloqueado: _viewModel.isLoading,
      aoConfirmar: _excluir,
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
