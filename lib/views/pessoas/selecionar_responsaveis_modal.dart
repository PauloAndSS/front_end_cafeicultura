import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/widgets/lista_papel_paginada.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<List<Pessoa>?> mostrarSelecaoResponsaveis({
  required BuildContext context,
  required CarregarPessoasMixin viewModel,
  required List<Pessoa> selecionadosAtuais,
}) {
  return showModalBottomSheet<List<Pessoa>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SelecionarResponsaveisSheet(
      viewModel: viewModel,
      selecionadosAtuais: selecionadosAtuais,
    ),
  );
}

class _SelecionarResponsaveisSheet extends StatefulWidget {
  final CarregarPessoasMixin viewModel;
  final List<Pessoa> selecionadosAtuais;

  const _SelecionarResponsaveisSheet({
    required this.viewModel,
    required this.selecionadosAtuais,
  });

  @override
  State<_SelecionarResponsaveisSheet> createState() =>
      _SelecionarResponsaveisSheetState();
}

class _SelecionarResponsaveisSheetState
    extends State<_SelecionarResponsaveisSheet> {
  final _buscaController = TextEditingController();

  final Map<int, Pessoa> _selecionados = {};

  String _termoBusca = '';

  @override
  void initState() {
    super.initState();

    for (final pessoa in widget.selecionadosAtuais) {
      if (pessoa.id != null) _selecionados[pessoa.id!] = pessoa;
    }

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

  void _alternar(int id, Pessoa pessoa, bool marcado) {
    setState(() {
      if (marcado) {
        _selecionados[id] = pessoa;
      } else {
        _selecionados.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final alturaSheet = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: alturaSheet,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DefaultTabController(
          length: categoriasDeResponsavel.length,
          child: Column(
            children: [
              const CabecalhoModal(titulo: 'Selecionar responsáveis'),
              CampoBuscaModal(
                controller: _buscaController,
                dica: 'Buscar por nome',
              ),
              BarraDeAbas(
                rolavel: true,
                abas: [
                  for (final papel in categoriasDeResponsavel)
                    Tab(text: papel.tituloPlural),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final papel in categoriasDeResponsavel)
                      ListaPapelPaginada(
                        catalogo: widget.viewModel,
                        papel: papel,
                        termoBusca: _termoBusca,
                        construirItem: (context, papelPessoa) => _construirItem(
                          papelPessoa.id!,
                          papelPessoa.pessoa,
                        ),
                      ),
                  ],
                ),
              ),
              RodapeConfirmarModal(
                quantidadeSelecionada: _selecionados.length,
                aoConfirmar: () =>
                    Navigator.of(context).pop(_selecionados.values.toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirItem(int id, Pessoa pessoa) {
    return CheckboxListTile(
      value: _selecionados.containsKey(id),
      activeColor: AppCores.verdePrimario,
      title: Text(pessoa.nomeParaExibicao),
      subtitle: Text(
        pessoa.documentoFormatado,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
      onChanged: (marcado) => _alternar(id, pessoa, marcado == true),
    );
  }
}
