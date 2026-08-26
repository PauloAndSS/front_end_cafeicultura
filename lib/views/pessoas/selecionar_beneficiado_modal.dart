import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<Pessoa?> mostrarSelecaoBeneficiado({
  required BuildContext context,
  required List<Pessoa> pessoas,
  Set<int> idsSugeridos = const {},
  Pessoa? selecionadoAtual,
  String titulo = 'Selecionar beneficiado',
  String mensagemSemPessoas = 'Nenhuma pessoa cadastrada.',
}) {
  return mostrarPainelModal<Pessoa>(
    context: context,
    construir: (_) => _SelecionarBeneficiadoSheet(
      pessoas: pessoas,
      idsSugeridos: idsSugeridos,
      selecionadoAtual: selecionadoAtual,
      titulo: titulo,
      mensagemSemPessoas: mensagemSemPessoas,
    ),
  );
}

class _SelecionarBeneficiadoSheet extends StatefulWidget {
  final List<Pessoa> pessoas;
  final Set<int> idsSugeridos;
  final Pessoa? selecionadoAtual;
  final String titulo;
  final String mensagemSemPessoas;

  const _SelecionarBeneficiadoSheet({
    required this.pessoas,
    required this.idsSugeridos,
    required this.selecionadoAtual,
    required this.titulo,
    required this.mensagemSemPessoas,
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

  List<Pessoa> get _visiveis {
    if (_termoBusca.isEmpty) return widget.pessoas;

    return widget.pessoas
        .where((pessoa) =>
            pessoa.nomeParaExibicao.toLowerCase().contains(_termoBusca))
        .toList();
  }

  bool _ehSugerido(Pessoa pessoa) =>
      pessoa.id != null && widget.idsSugeridos.contains(pessoa.id);

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
            CabecalhoModal(titulo: widget.titulo),
            CampoBuscaModal(
              controller: _buscaController,
              dica: 'Buscar por nome',
            ),
            Expanded(child: _construirCorpo()),
          ],
        ),
      ),
    );
  }

  Widget _construirCorpo() {
    final visiveis = _visiveis;

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: _termoBusca.isEmpty ? Icons.group_off_outlined : Icons.search,
        mensagem: _termoBusca.isEmpty
            ? widget.mensagemSemPessoas
            : 'Ninguém encontrado com "$_termoBusca".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length,
      itemBuilder: (context, index) {
        final pessoa = visiveis[index];
        final marcado = pessoa.id == widget.selecionadoAtual?.id;

        return ListTile(
          leading: Icon(
            marcado ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: marcado ? AppCores.verdePrimario : Colors.black38,
          ),
          title: Text(pessoa.nomeParaExibicao),
          subtitle: _ehSugerido(pessoa)
              ? const Text(
                  'Responsável',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                )
              : null,
          onTap: () => Navigator.of(context).pop(pessoa),
        );
      },
    );
  }
}
