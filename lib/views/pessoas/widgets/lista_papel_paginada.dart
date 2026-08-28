import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

/// A lista de uma categoria dentro de um painel de seleção: carrega sob
/// demanda, pagina ao rolar e filtra pelo termo de busca do painel.
///
/// A busca alcança **só o que já foi carregado** — o backend ainda não expõe
/// filtro por nome. Por isso a lista continua paginando enquanto o termo não
/// encontra ninguém.
class ListaPapelPaginada extends StatefulWidget {
  final CarregarPessoasMixin catalogo;
  final TipoPapel papel;
  final String termoBusca;
  final Widget Function(BuildContext contexto, PapelPessoa papelPessoa)
      construirItem;

  const ListaPapelPaginada({
    super.key,
    required this.catalogo,
    required this.papel,
    required this.termoBusca,
    required this.construirItem,
  });

  @override
  State<ListaPapelPaginada> createState() => _ListaPapelPaginadaState();
}

class _ListaPapelPaginadaState extends State<ListaPapelPaginada>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_aoRolar);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.catalogo.carregarCategoria(widget.papel);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_aoRolar);
    _scrollController.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.catalogo.carregarMaisDe(widget.papel);
    }
  }

  List<PapelPessoa> _filtrar(List<PapelPessoa> todos) {
    final termo = widget.termoBusca;

    if (termo.isEmpty) return todos;

    return todos
        .where((papel) =>
            papel.pessoa.nomeParaExibicao.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: widget.catalogo,
      builder: (context, _) => _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    final catalogo = widget.catalogo;
    final papel = widget.papel;

    final carregados = catalogo.pessoasDe(papel);

    if (catalogo.isCarregando(papel)) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.verdePrimario),
      );
    }

    final mensagemErro = catalogo.mensagemErroDe(papel);

    if (mensagemErro != null && carregados.isEmpty) {
      return EstadoVazio(
        icone: Icons.error_outline,
        mensagem: mensagemErro,
        acao: CustomButton(
          text: 'Tentar novamente',
          onPressed: () => catalogo.carregarCategoria(papel, recarregar: true),
        ),
      );
    }

    final visiveis = _filtrar(carregados);

    if (visiveis.isEmpty && catalogo.temMaisDe(papel)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) catalogo.carregarMaisDe(papel);
      });

      return const EstadoVazio(
        icone: Icons.search,
        mensagem: 'Procurando mais pessoas...',
        acao: Padding(
          padding: EdgeInsets.only(top: 16),
          child: CircularProgressIndicator(color: AppCores.verdePrimario),
        ),
      );
    }

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.group_off_outlined,
        mensagem: widget.termoBusca.isEmpty
            ? 'Nenhum ${papel.rotulo} cadastrado.'
            : 'Nenhum ${papel.rotulo} encontrado com "${widget.termoBusca}".',
      );
    }

    final carregandoMais = catalogo.isCarregandoMais(papel);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length + (carregandoMais ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == visiveis.length) {
          return const RodapePaginacao(carregando: true);
        }

        return widget.construirItem(context, visiveis[index]);
      },
    );
  }
}
