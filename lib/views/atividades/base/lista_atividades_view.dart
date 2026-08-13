import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/filtro_status_atividade.dart';
import 'package:provider/provider.dart';

const _verdePrimario = Color(0xFF67835C);

/// Aba de listagem de um tipo de atividade agrícola.
///
/// A tela concreta entrega o ViewModel e os rótulos; toda a coreografia —
/// escopo da propriedade, filtro por status, recarga após cadastro ou edição —
/// mora aqui.
///
/// O ViewModel é criado e descartado pela tela concreta: esta é `stateful` só
/// pelo filtro e pelo `AutomaticKeepAliveClientMixin`, que preserva a lista ao
/// trocar de aba.
class ListaAtividadesView<T extends EventoAgricola>
    extends StatefulWidget {
  final ListaAtividadesDaPropriedadeViewModel<T> viewModel;

  /// 'Novo Trato' — rótulo do botão flutuante.
  final String rotuloCadastrar;

  /// Frase do estado vazio. É a atividade que a escreve, e não a base, por
  /// concordância: 'tratos culturais finalizados' e 'colheitas finalizadas'
  /// não saem do mesmo molde.
  final String Function(StatusEvento status, String nomePropriedade)
      construirMensagemVazia;

  final IconData iconeCard;

  /// Tela de cadastro. Deve devolver `true` no pop quando cadastrar.
  final WidgetBuilder construirTelaCadastro;

  /// Tela de detalhes. Deve devolver `true` no pop quando algo mudar.
  final Widget Function(BuildContext context, T atividade, String nomeTalhao)
      construirTelaDetalhes;

  const ListaAtividadesView({
    super.key,
    required this.viewModel,
    required this.rotuloCadastrar,
    required this.construirMensagemVazia,
    required this.iconeCard,
    required this.construirTelaCadastro,
    required this.construirTelaDetalhes,
  });

  @override
  State<ListaAtividadesView<T>> createState() => _ListaAtividadesViewState<T>();
}

class _ListaAtividadesViewState<T extends EventoAgricola>
    extends State<ListaAtividadesView<T>> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StatusEvento _filtroSelecionado = StatusEvento.emAndamento;

  ListaAtividadesDaPropriedadeViewModel<T> get _viewModel => widget.viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVM.idPropriedadeSelecionada;

    if (idPropriedade == null) return;

    // `carregar` notifica de forma síncrona: chamar durante a resolução de
    // dependências dispararia rebuild no meio do frame. A guarda de escopo do
    // ViewModel é que evita a rebusca quando a propriedade não mudou.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.carregar(idPropriedade);
    });
  }

  Future<void> _abrirCadastro() async {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();

    if (propriedadesVM.idPropriedadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma propriedade primeiro.')),
      );
      return;
    }

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: widget.construirTelaCadastro),
    );

    if (cadastrou == true && mounted) _recarregar();
  }

  Future<void> _abrirDetalhes(T atividade) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => widget.construirTelaDetalhes(
          context,
          atividade,
          _viewModel.nomeDoTalhao(atividade.idTalhao),
        ),
      ),
    );

    if (alterou == true && mounted) _recarregar();
  }

  void _recarregar() {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    if (idPropriedade != null) {
      _viewModel.carregar(idPropriedade, forcar: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: _verdePrimario,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.rotuloCadastrar,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              child: SizedBox(
                width: double.infinity,
                child: FiltroStatusAtividade(
                  selecionado: _filtroSelecionado,
                  onSelecionar: (novoFiltro) =>
                      setState(() => _filtroSelecionado = novoFiltro),
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return _construirCorpo(_nomeDaPropriedade(propriedadesVM));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCorpo(String nomePropriedade) {
    final filtradas = _viewModel.porStatus(_filtroSelecionado);

    return CorpoComEstado(
      isLoading: _viewModel.isLoading,
      mensagemErro: _viewModel.mensagemErro,
      vazio: filtradas.isEmpty,
      construirVazio: (_) => _construirEstadoVazio(nomePropriedade),
      construirConteudo: (_) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
        itemCount: filtradas.length,
        itemBuilder: (context, index) {
          final atividade = filtradas[index];

          return AtividadeCard(
            atividade: atividade,
            nomeTalhao: _viewModel.nomeDoTalhao(atividade.idTalhao),
            icone: widget.iconeCard,
            onTap: () => _abrirDetalhes(atividade),
          );
        },
      ),
    );
  }

  Widget _construirEstadoVazio(String nomePropriedade) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Text(
          widget.construirMensagemVazia(_filtroSelecionado, nomePropriedade),
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _nomeDaPropriedade(PropriedadesUsuarioViewModel propriedadesVM) {
    if (propriedadesVM.idPropriedadeSelecionada == null ||
        propriedadesVM.propriedades.isEmpty) {
      return 'esta propriedade';
    }

    final propriedade = propriedadesVM.propriedades.firstWhere(
      (propriedade) =>
          propriedade.id == propriedadesVM.idPropriedadeSelecionada,
      orElse: () => propriedadesVM.propriedades.first,
    );

    return propriedade.nome;
  }
}
