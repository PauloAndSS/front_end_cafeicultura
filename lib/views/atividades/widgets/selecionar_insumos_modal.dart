import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo_utilizado.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/cadastrar_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/quantidade_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);

/// Abre a seleção de insumos utilizados numa atividade agrícola.
///
/// Trabalha com [InsumoUtilizado] na entrada e na saída — e não com ids soltos —
/// porque a descrição e a medida precisam sobreviver ao PATCH, que devolve só
/// mensagem de sucesso.
///
/// Devolve `null` se o usuário fechar sem confirmar.
Future<List<InsumoUtilizado>?> mostrarSelecaoInsumos({
  required BuildContext context,
  required CarregarInsumosMixin viewModel,
  required List<InsumoUtilizado> selecionadosAtuais,
  required int idProprietario,
}) {
  return showModalBottomSheet<List<InsumoUtilizado>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SelecionarInsumosSheet(
      viewModel: viewModel,
      selecionadosAtuais: selecionadosAtuais,
      idProprietario: idProprietario,
    ),
  );
}

class _SelecionarInsumosSheet extends StatefulWidget {
  final CarregarInsumosMixin viewModel;
  final List<InsumoUtilizado> selecionadosAtuais;
  final int idProprietario;

  const _SelecionarInsumosSheet({
    required this.viewModel,
    required this.selecionadosAtuais,
    required this.idProprietario,
  });

  @override
  State<_SelecionarInsumosSheet> createState() =>
      _SelecionarInsumosSheetState();
}

class _SelecionarInsumosSheetState extends State<_SelecionarInsumosSheet> {
  final _buscaController = TextEditingController();

  /// Chaveado pelo id do insumo: o mesmo insumo nunca entra duas vezes, e
  /// remarcar substitui a quantidade em vez de duplicar a linha.
  final Map<int, InsumoUtilizado> _selecionados = {};

  String _termoBusca = '';

  @override
  void initState() {
    super.initState();

    for (final insumo in widget.selecionadosAtuais) {
      _selecionados[insumo.idInsumo] = insumo;
    }

    _buscaController.addListener(_aoBuscar);

    if (!widget.viewModel.insumosCarregados) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.carregarInsumos();
      });
    }
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

  List<Insumo> _filtrar(List<Insumo> todos) {
    if (_termoBusca.isEmpty) return todos;

    return todos
        .where((insumo) => insumo.descricao.toLowerCase().contains(_termoBusca))
        .toList();
  }

  Future<void> _abrirCadastroInsumo() async {
    final criado = await mostrarCadastroInsumo(
      context: context,
      viewModel: widget.viewModel,
      idProprietario: widget.idProprietario,
    );

    if (criado == null || !mounted) return;

    // Quem acabou de cadastrar quer usar: já pede a quantidade.
    await _marcar(criado);
  }

  /// Pede a quantidade e registra a seleção. Cancelar o diálogo deixa o insumo
  /// desmarcado.
  Future<void> _marcar(Insumo insumo) async {
    final id = insumo.id;
    if (id == null) return;

    final quantidade = await mostrarQuantidadeInsumo(
      context: context,
      insumo: insumo,
      quantidadeAtual: _selecionados[id]?.qtdUsada,
    );

    if (quantidade == null || !mounted) return;

    setState(() {
      _selecionados[id] = InsumoUtilizado(
        idInsumo: id,
        descricao: insumo.descricao,
        medida: insumo.medida,
        qtdUsada: quantidade,
      );
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
        child: Column(
          children: [
            _construirCabecalho(),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, child) => _construirConteudo(),
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
              'Insumos utilizados',
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

  Widget _construirConteudo() {
    final temCatalogo = widget.viewModel.insumos.isNotEmpty;

    return Column(
      children: [
        _construirAcaoCadastrar(),
        // Buscar num catálogo vazio é só ruído na tela.
        if (temCatalogo) _construirCampoBusca(),
        Expanded(child: _construirCorpo()),
      ],
    );
  }

  /// Fica fora do corpo, e não dentro do estado vazio, para o cadastro nunca
  /// depender de o GET ter dado certo: com o catálogo indisponível, esta é a
  /// única saída da tela.
  Widget _construirAcaoCadastrar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: InkWell(
        onTap: _abrirCadastroInsumo,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _verdePrimario),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: _verdePrimario),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cadastrar novo insumo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _verdePrimario,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCampoBusca() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar por descrição',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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

    if (vm.isCarregandoInsumos) {
      return const Center(
        child: CircularProgressIndicator(color: _verdePrimario),
      );
    }

    if (vm.mensagemErroInsumos != null && vm.insumos.isEmpty) {
      return _construirAviso(
        icone: Icons.cloud_off_outlined,
        mensagem:
            '${vm.mensagemErroInsumos!}\n\nVocê ainda pode cadastrar um insumo novo pelo botão acima.',
        acao: CustomButton(
          text: 'Tentar novamente',
          onPressed: vm.carregarInsumos,
        ),
      );
    }

    if (vm.insumos.isEmpty) {
      return _construirAviso(
        icone: Icons.inventory_2_outlined,
        mensagem:
            'Você ainda não tem insumos cadastrados.\nCadastre o primeiro para lançá-lo nesta atividade.',
        acao: CustomButton(
          text: 'Cadastrar insumo',
          onPressed: _abrirCadastroInsumo,
        ),
      );
    }

    final visiveis = _filtrar(vm.insumos);

    if (visiveis.isEmpty) {
      return _construirAviso(
        icone: Icons.search_off,
        mensagem: 'Nenhum insumo encontrado com "$_termoBusca".',
        acao: CustomButton(
          text: 'Cadastrar insumo',
          onPressed: _abrirCadastroInsumo,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: visiveis.length,
      itemBuilder: (context, index) {
        final insumo = visiveis[index];
        final id = insumo.id!;
        final selecionado = _selecionados[id];

        // ListTile em vez de CheckboxListTile: tocar num item já marcado precisa
        // reabrir a quantidade para edição, e não desmarcá-lo. Desmarcar é o
        // toque no checkbox.
        return ListTile(
          leading: Checkbox(
            value: selecionado != null,
            activeColor: _verdePrimario,
            onChanged: (marcado) {
              if (marcado == true) {
                _marcar(insumo);
              } else {
                setState(() => _selecionados.remove(id));
              }
            },
          ),
          title: Text(insumo.descricao),
          subtitle: Text(
            selecionado == null
                ? insumo.medida.rotulo
                : 'Quantidade: ${selecionado.qtdFormatada}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: selecionado == null
              ? null
              : const Icon(Icons.edit_outlined, color: Colors.black38, size: 20),
          onTap: () => _marcar(insumo),
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
