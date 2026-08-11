import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_responsaveis_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);

/// Abre a seleção de responsáveis de uma atividade agrícola.
///
/// Devolve [Pessoa], e não [PapelPessoa], porque é [Pessoa] que a atividade
/// guarda: o payload de leitura de um evento traz a pessoa (nome, cpf,
/// endereço) sem o campo `papel`, então não há como reconstruir um
/// [PapelPessoa] do outro lado.
///
/// Guardar o objeto, e não só o id, é o que mantém a seleção independente da
/// paginação: um responsável já vinculado que só apareça na página 3 continua
/// marcado mesmo que o usuário confirme sem rolar até lá.
///
/// Devolve `null` se o usuário fechar sem confirmar.
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

  /// Chaveado por id porque `Pessoa` não implementa `==`: a mesma pessoa vinda
  /// de duas cargas seria contada duas vezes num Set de objetos.
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
            _construirCabecalho(),
            _construirCampoBusca(),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, child) => _construirCorpo(),
              ),
            ),
            _construirRodape(),
          ],
        ),
      ),
    );
  }

  Widget _construirCabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Selecionar responsáveis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _verdePrimario,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Fechar sem alterar',
          ),
        ],
      ),
    );
  }

  Widget _construirCampoBusca() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome',
          prefixIcon: const Icon(Icons.search),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _cinzaBorda),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _cinzaBorda),
          ),
        ),
      ),
    );
  }

  Widget _construirCorpo() {
    final vm = widget.viewModel;

    if (vm.isCarregandoResponsaveis) {
      return const Center(
        child: CircularProgressIndicator(color: _verdePrimario),
      );
    }

    if (vm.mensagemErroResponsaveis != null && vm.responsaveis.isEmpty) {
      return _construirAviso(
        icone: Icons.error_outline,
        mensagem: vm.mensagemErroResponsaveis!,
        acao: CustomButton(
          text: 'Tentar novamente',
          onPressed: vm.carregarResponsaveis,
        ),
      );
    }

    final visiveis = _filtrar(vm.responsaveis);

    // Uma página inteira de clientes e fornecedores some no filtro de papel:
    // a lista pode ficar vazia com gente elegível na página seguinte.
    if (visiveis.isEmpty && vm.temMaisResponsaveis) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) vm.carregarMaisResponsaveis();
      });

      return _construirAviso(
        icone: Icons.search,
        mensagem: 'Procurando mais pessoas...',
        acao: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: CircularProgressIndicator(color: _verdePrimario),
        ),
      );
    }

    if (visiveis.isEmpty) {
      return _construirAviso(
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
              child: CircularProgressIndicator(color: _verdePrimario),
            ),
          );
        }

        final papel = visiveis[index];

        // O id do **papel** é o que o backend aceita em `responsaveisIds`, e é
        // ele que chaveia a seleção. Hoje coincide com `papel.pessoa.id` porque
        // a API devolve o registro achatado com um id só.
        final id = papel.id!;

        return CheckboxListTile(
          value: _selecionados.containsKey(id),
          activeColor: _verdePrimario,
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

  Widget _construirAviso({
    required IconData icone,
    required String mensagem,
    Widget? acao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            if (acao != null) ...[const SizedBox(height: 24), acao],
          ],
        ),
      ),
    );
  }

  Widget _construirRodape() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _cinzaBorda)),
      ),
      child: CustomButton(
        text: 'Confirmar (${_selecionados.length})',
        onPressed: () =>
            Navigator.of(context).pop(_selecionados.values.toList()),
      ),
    );
  }
}
