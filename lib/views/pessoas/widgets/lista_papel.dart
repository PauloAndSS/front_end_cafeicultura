import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

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

  const ListaPapel({
    super.key,
    required this.catalogo,
    required this.papel,
    required this.termoBusca,
    required this.construirItem,
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

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.group_off_outlined,
        mensagem: widget.termoBusca.isEmpty
            ? 'Nenhum ${papel.rotulo} cadastrado.'
            : 'Nenhum ${papel.rotulo} encontrado com "${widget.termoBusca}".',
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
