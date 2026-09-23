import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<List<Variedade>?> mostrarSelecaoVariedades({
  required BuildContext context,
  required List<Variedade> variedades,
  required List<Variedade> selecionadasAtuais,
}) {
  return mostrarPainelModal<List<Variedade>>(
    context: context,
    construir: (_) => _SelecionarVariedadesSheet(
      variedades: variedades,
      selecionadasAtuais: selecionadasAtuais,
    ),
  );
}

class _SelecionarVariedadesSheet extends StatefulWidget {
  final List<Variedade> variedades;
  final List<Variedade> selecionadasAtuais;

  const _SelecionarVariedadesSheet({
    required this.variedades,
    required this.selecionadasAtuais,
  });

  @override
  State<_SelecionarVariedadesSheet> createState() =>
      _SelecionarVariedadesSheetState();
}

class _SelecionarVariedadesSheetState
    extends State<_SelecionarVariedadesSheet> {
  static const _apoioGenerica = 'Variedade que não está na lista';

  final _buscaController = TextEditingController();

  final Map<int, Variedade> _selecionadas = {};

  String _termoBusca = '';

  @override
  void initState() {
    super.initState();

    for (final variedade in widget.selecionadasAtuais) {
      _selecionadas[variedade.id] = variedade;
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

  List<Variedade> get _genericas =>
      widget.variedades.where((variedade) => variedade.ehGenerica).toList();

  List<Variedade> get _cultivaresFiltradas => widget.variedades
      .where((variedade) => !variedade.ehGenerica)
      .where(
        (variedade) => variedade.descricao.toLowerCase().contains(_termoBusca),
      )
      .toList();

  void _alternar(Variedade variedade, bool marcada) {
    setState(() {
      if (marcada) {
        _selecionadas[variedade.id] = variedade;
      } else {
        _selecionadas.remove(variedade.id);
      }
    });
  }

  void _confirmar() {
    Navigator.of(context).pop(_selecionadas.values.toList());
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
        child: Column(
          children: [
            const CabecalhoModal(titulo: 'Selecionar variedades'),
            CampoBuscaModal(
              controller: _buscaController,
              dica: 'Buscar variedade',
            ),
            const SizedBox(height: 8),
            Expanded(child: _construirLista()),
            RodapeConfirmarModal(
              quantidadeSelecionada: _selecionadas.length,
              aoConfirmar: _confirmar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista() {
    final cultivares = _cultivaresFiltradas;
    final genericas = _genericas;
    final buscaSemResultado = cultivares.isEmpty && _termoBusca.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        if (buscaSemResultado)
          const EstadoVazio(
            mensagem: 'Nenhuma variedade encontrada.',
            icone: Icons.search_off,
          ),
        ...cultivares.map(_construirItem),
        if (genericas.isNotEmpty &&
            (cultivares.isNotEmpty || buscaSemResultado))
          const Divider(),
        ...genericas.map(_construirItem),
      ],
    );
  }

  Widget _construirItem(Variedade variedade) {
    return CheckboxListTile(
      value: _selecionadas.containsKey(variedade.id),
      title: Text(variedade.descricao),
      subtitle: variedade.ehGenerica ? const Text(_apoioGenerica) : null,
      onChanged: (marcada) => _alternar(variedade, marcada == true),
    );
  }
}
