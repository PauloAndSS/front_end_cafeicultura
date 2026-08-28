import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/widgets/lista_papel_paginada.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

/// Escolhe **um** beneficiado, navegando o catálogo de pessoas por categoria.
///
/// [sugeridos] são os responsáveis já ligados à atividade: eles ganham a
/// primeira aba porque quase sempre são a resposta. Com uma categoria só e
/// nenhum sugerido — o caso do fornecedor no cadastro de insumo — o painel não
/// desenha aba nenhuma.
Future<Pessoa?> mostrarSelecaoBeneficiado({
  required BuildContext context,
  required CarregarPessoasMixin catalogo,
  required List<TipoPapel> categorias,
  List<Pessoa> sugeridos = const [],
  Pessoa? selecionadoAtual,
  String titulo = 'Selecionar beneficiado',
}) {
  return mostrarPainelModal<Pessoa>(
    context: context,
    construir: (_) => _SelecionarBeneficiadoSheet(
      catalogo: catalogo,
      categorias: categorias,
      sugeridos: sugeridos,
      selecionadoAtual: selecionadoAtual,
      titulo: titulo,
    ),
  );
}

class _SelecionarBeneficiadoSheet extends StatefulWidget {
  final CarregarPessoasMixin catalogo;
  final List<TipoPapel> categorias;
  final List<Pessoa> sugeridos;
  final Pessoa? selecionadoAtual;
  final String titulo;

  const _SelecionarBeneficiadoSheet({
    required this.catalogo,
    required this.categorias,
    required this.sugeridos,
    required this.selecionadoAtual,
    required this.titulo,
  });

  @override
  State<_SelecionarBeneficiadoSheet> createState() =>
      _SelecionarBeneficiadoSheetState();
}

class _SelecionarBeneficiadoSheetState
    extends State<_SelecionarBeneficiadoSheet> {
  final _buscaController = TextEditingController();

  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_aoBuscar);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _aoBuscar() {
    final termo = _buscaController.text.trim().toLowerCase();
    if (termo == _termoBusca) return;
    setState(() => _termoBusca = termo);
  }

  bool get _temAbaDeSugeridos => widget.sugeridos.isNotEmpty;

  int get _quantidadeDeAbas =>
      widget.categorias.length + (_temAbaDeSugeridos ? 1 : 0);

  bool get _semAbas => _quantidadeDeAbas <= 1;

  @override
  Widget build(BuildContext context) {
    final alturaSheet = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: alturaSheet,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _semAbas ? _construirSemAbas() : _construirComAbas(),
      ),
    );
  }

  Widget _construirSemAbas() {
    return Column(
      children: [
        CabecalhoModal(titulo: widget.titulo),
        CampoBuscaModal(controller: _buscaController, dica: 'Buscar por nome'),
        Expanded(child: _construirCategoria(widget.categorias.single)),
      ],
    );
  }

  Widget _construirComAbas() {
    return DefaultTabController(
      length: _quantidadeDeAbas,
      child: Column(
        children: [
          CabecalhoModal(titulo: widget.titulo),
          CampoBuscaModal(controller: _buscaController, dica: 'Buscar por nome'),
          BarraDeAbas(
            rolavel: true,
            abas: [
              if (_temAbaDeSugeridos) const Tab(text: 'Responsáveis'),
              for (final papel in widget.categorias)
                Tab(text: papel.tituloPlural),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                if (_temAbaDeSugeridos) _construirSugeridos(),
                for (final papel in widget.categorias)
                  _construirCategoria(papel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCategoria(TipoPapel papel) {
    return ListaPapelPaginada(
      catalogo: widget.catalogo,
      papel: papel,
      termoBusca: _termoBusca,
      construirItem: (context, papelPessoa) => _construirItem(
        papelPessoa.pessoa,
        legenda: papelPessoa.pessoa.documentoFormatado,
      ),
    );
  }

  Widget _construirSugeridos() {
    final visiveis = _termoBusca.isEmpty
        ? widget.sugeridos
        : widget.sugeridos
            .where((pessoa) =>
                pessoa.nomeParaExibicao.toLowerCase().contains(_termoBusca))
            .toList();

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.search,
        mensagem: 'Nenhum responsável encontrado com "$_termoBusca".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length,
      itemBuilder: (context, index) =>
          _construirItem(visiveis[index], legenda: 'Responsável'),
    );
  }

  Widget _construirItem(Pessoa pessoa, {required String legenda}) {
    final marcado = pessoa.id != null && pessoa.id == widget.selecionadoAtual?.id;

    return ListTile(
      leading: Icon(
        marcado ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: marcado ? AppCores.verdePrimario : Colors.black38,
      ),
      title: Text(pessoa.nomeParaExibicao),
      subtitle: Text(
        legenda,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
      onTap: () => Navigator.of(context).pop(pessoa),
    );
  }
}
