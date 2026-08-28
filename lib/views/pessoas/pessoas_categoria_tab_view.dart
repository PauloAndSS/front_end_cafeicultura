import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/pessoas_da_categoria_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/detalhes_pessoa_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/widgets/pessoas_card_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

class PessoasCategoriaTabView extends StatefulWidget {
  final PessoasDaCategoriaViewModel viewModel;

  const PessoasCategoriaTabView({super.key, required this.viewModel});

  @override
  State<PessoasCategoriaTabView> createState() =>
      _PessoasCategoriaTabViewState();
}

class _PessoasCategoriaTabViewState extends State<PessoasCategoriaTabView>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  TipoPapel get _papel => widget.viewModel.papel;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_aoRolar);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.carregado) return;

      widget.viewModel.carregar();
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
      widget.viewModel.carregarMais();
    }
  }

  Future<void> _abrirDetalhes(PapelPessoa papelPessoa) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesPessoaView(papelPessoa: papelPessoa),
      ),
    );

    if (alterou == true && mounted) widget.viewModel.carregar();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        return CorpoComEstado(
          isLoading: vm.isLoading,
          mensagemErro: vm.pessoas.isEmpty ? vm.mensagemErro : null,
          vazio: vm.pessoas.isEmpty,
          aoTentarNovamente: vm.carregar,
          construirVazio: (_) => EstadoVazio(
            icone: Icons.group_off_outlined,
            mensagem: 'Nenhum ${_papel.rotulo} cadastrado.',
          ),
          construirConteudo: (_) => _construirGrade(),
        );
      },
    );
  }

  Widget _construirGrade() {
    final vm = widget.viewModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final papelPessoa = vm.pessoas[index];

                return PessoaCardWidget(
                  nome: papelPessoa.pessoa.nomeParaExibicao,
                  subtitulo: papelPessoa.pessoa.documentoFormatado,
                  onTap: () => _abrirDetalhes(papelPessoa),
                );
              },
              childCount: vm.pessoas.length,
            ),
          ),
          SliverToBoxAdapter(
            child: RodapePaginacao(
              carregando: vm.isLoadingMore,
              mensagemErro: vm.mensagemErro,
              aoTentarNovamente: vm.carregarMais,
            ),
          ),
        ],
      ),
    );
  }
}
