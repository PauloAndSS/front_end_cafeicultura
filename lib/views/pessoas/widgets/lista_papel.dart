import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/acoes_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

/// A lista de uma categoria dentro de um painel de seleção: carrega sob
/// demanda e filtra pelo termo de busca do painel.
///
/// A rota do papel devolve a categoria inteira numa resposta só, então a busca
/// alcança todo mundo — o filtro é local porque o backend não expõe `?busca=`.
class ListaPapel extends StatefulWidget {
  final CarregarPessoasMixin catalogo;
  final TipoPapel papel;
  final String termoBusca;
  final Widget Function(BuildContext contexto, PapelPessoa papelPessoa)
  construirItem;
  final void Function(PapelPessoa criado) aoCadastrar;

  const ListaPapel({
    super.key,
    required this.catalogo,
    required this.papel,
    required this.termoBusca,
    required this.construirItem,
    required this.aoCadastrar,
  });

  @override
  State<ListaPapel> createState() => _ListaPapelState();
}

class _ListaPapelState extends State<ListaPapel>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.catalogo.carregarCategoria(widget.papel);
    });
  }

  List<PapelPessoa> _filtrar(List<PapelPessoa> todos) {
    final termo = widget.termoBusca;

    if (termo.isEmpty) return todos;

    return todos
        .where(
          (papel) =>
              papel.pessoa.nomeParaExibicao.toLowerCase().contains(termo),
        )
        .toList();
  }

  Future<void> _cadastrar() async {
    final resultado = await cadastrarPessoaDoPapel(
      context,
      widget.catalogo,
      widget.papel,
    );

    if (!mounted) return;

    if (resultado case PessoaLocalizada(:final papel)) {
      widget.aoCadastrar(papel);
    }
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

    if (catalogo.isCarregando(papel)) {
      return const Center(child: CircularProgressIndicator());
    }

    final mensagemErro = catalogo.mensagemErroDe(papel);

    return Column(
      children: [
        AcaoCadastrarNoPainel(
          rotulo: 'Cadastrar novo ${papel.rotulo}',
          aoTocar: _cadastrar,
        ),
        if (mensagemErro != null)
          MensagemDeErro(
            mensagem: mensagemErro,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            aoTentarNovamente: () =>
                catalogo.carregarCategoria(papel, recarregar: true),
          ),
        Expanded(child: _construirLista(_filtrar(catalogo.pessoasDe(papel)))),
      ],
    );
  }

  Widget _construirLista(List<PapelPessoa> visiveis) {
    if (visiveis.isEmpty) {
      final semBusca = widget.termoBusca.isEmpty;

      return EstadoVazio(
        icone: semBusca
            ? Icons.person_add_alt_1_outlined
            : Icons.group_off_outlined,
        mensagem: semBusca
            ? 'Nenhum ${widget.papel.rotulo} cadastrado.\n'
                  'Use "Cadastrar novo" acima para selecioná-lo aqui.'
            : 'Nenhum ${widget.papel.rotulo} encontrado com '
                  '"${widget.termoBusca}".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length,
      itemBuilder: (context, index) =>
          widget.construirItem(context, visiveis[index]),
    );
  }
}
