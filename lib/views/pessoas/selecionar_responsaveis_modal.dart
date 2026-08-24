import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_responsaveis_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

Future<List<Pessoa>?> mostrarSelecaoResponsaveis({
  required BuildContext context,
  required CarregarResponsaveisMixin viewModel,
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
  final CarregarResponsaveisMixin viewModel;
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
  final _scrollController = ScrollController();

  final Map<int, Pessoa> _selecionados = {};

  String _termoBusca = '';

  @override
  void initState() {
    super.initState();

    for (final pessoa in widget.selecionadosAtuais) {
      if (pessoa.id != null) _selecionados[pessoa.id!] = pessoa;
    }

    _scrollController.addListener(_aoRolar);
    _buscaController.addListener(_aoBuscar);

    if (!widget.viewModel.responsaveisCarregados) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.carregarResponsaveis();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_aoRolar);
    _scrollController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.carregarMaisResponsaveis();
    }
  }

  void _aoBuscar() {
    final termo = _buscaController.text.trim().toLowerCase();
    if (termo == _termoBusca) return;
    setState(() => _termoBusca = termo);
  }

  List<PapelPessoa> _filtrar(List<PapelPessoa> todos) {
    if (_termoBusca.isEmpty) return todos;

    return todos
        .where((papel) =>
            papel.pessoa.nomeParaExibicao.toLowerCase().contains(_termoBusca))
        .toList();
  }

  String _rotuloPapel(PapelPessoa papel) {
    if (papel is Funcionario) return 'Funcionário';
    if (papel is Meeiro) return 'Meeiro';
    return 'Prestador de serviço';
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
            const CabecalhoModal(titulo: 'Selecionar responsáveis'),
            CampoBuscaModal(controller: _buscaController, dica: 'Buscar por nome'),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, child) => _construirCorpo(),
              ),
            ),
            RodapeConfirmarModal(
              quantidadeSelecionada: _selecionados.length,
              aoConfirmar: () => Navigator.of(context).pop(_selecionados.values.toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCorpo() {
    final vm = widget.viewModel;

    if (vm.isCarregandoResponsaveis) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.verdePrimario),
      );
    }

    if (vm.mensagemErroResponsaveis != null && vm.responsaveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.error_outline,
        mensagem: vm.mensagemErroResponsaveis!,
        acao: CustomButton(
          text: 'Tentar novamente',
          onPressed: vm.carregarResponsaveis,
        ),
      );
    }

    final visiveis = _filtrar(vm.responsaveis);

    if (visiveis.isEmpty && vm.temMaisResponsaveis) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) vm.carregarMaisResponsaveis();
      });

      return EstadoVazio(
        icone: Icons.search,
        mensagem: 'Procurando mais pessoas...',
        acao: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: CircularProgressIndicator(color: AppCores.verdePrimario),
        ),
      );
    }

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.group_off_outlined,
        mensagem: _termoBusca.isEmpty
            ? 'Nenhum funcionário, meeiro ou prestador cadastrado.'
            : 'Ninguém encontrado com "$_termoBusca" entre as pessoas já carregadas.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length + (vm.isCarregandoMaisResponsaveis ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == visiveis.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppCores.verdePrimario),
            ),
          );
        }

        final papel = visiveis[index];

        final id = papel.id!;

        return CheckboxListTile(
          value: _selecionados.containsKey(id),
          activeColor: AppCores.verdePrimario,
          title: Text(papel.pessoa.nomeParaExibicao),
          subtitle: Text(
            _rotuloPapel(papel),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          onChanged: (marcado) {
            setState(() {
              if (marcado == true) {
                _selecionados[id] = papel.pessoa;
              } else {
                _selecionados.remove(id);
              }
            });
          },
        );
      },
    );
  }
}
