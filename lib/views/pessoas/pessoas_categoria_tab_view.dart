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
  @override
  bool get wantKeepAlive => true;

  TipoPapel get _papel => widget.viewModel.papel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.carregado) return;

      widget.viewModel.carregar();
    });
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

        return RefreshIndicator(
          onRefresh: vm.carregar,
          child: CorpoComEstado(
            isLoading: vm.isLoading,
            mensagemErro: vm.pessoas.isEmpty ? vm.mensagemErro : null,
            vazio: vm.pessoas.isEmpty,
            aoTentarNovamente: vm.carregar,
            manterConteudoAoRecarregar: true,
            construirVazio: (_) => EstadoVazio(
              icone: Icons.group_off_outlined,
              mensagem: 'Nenhum ${_papel.rotulo} cadastrado.',
            ),
            construirConteudo: (_) => _construirLista(),
          ),
        );
      },
    );
  }

  Widget _construirLista() {
    final vm = widget.viewModel;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverList.builder(
            itemCount: vm.pessoas.length,
            itemBuilder: (context, index) {
              final papelPessoa = vm.pessoas[index];

              return PessoaCardWidget(
                nome: papelPessoa.pessoa.nomeParaExibicao,
                iniciais: papelPessoa.pessoa.iniciais,
                subtitulo: papelPessoa.pessoa.documentoFormatado,
                onTap: () => _abrirDetalhes(papelPessoa),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
