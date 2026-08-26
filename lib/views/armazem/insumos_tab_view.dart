import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/acoes_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/detalhes_insumo_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/widgets/insumo_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

class InsumosTabView extends StatefulWidget {
  final InsumosViewModel viewModel;

  const InsumosTabView({super.key, required this.viewModel});

  @override
  State<InsumosTabView> createState() => _InsumosTabViewState();
}

class _InsumosTabViewState extends State<InsumosTabView>
    with AutomaticKeepAliveClientMixin {
  final _buscaController = TextEditingController();

  String _termoBusca = '';

  @override
  bool get wantKeepAlive => true;

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

  List<Insumo> _filtrar(List<Insumo> todos) {
    if (_termoBusca.isEmpty) return todos;

    return todos
        .where((insumo) => insumo.descricao.toLowerCase().contains(_termoBusca))
        .toList();
  }

  Future<void> _cadastrar() async {
    final criado = await abrirCadastroDeInsumo(context, widget.viewModel);

    if (criado == null || !mounted) return;

    mostrarSucesso(context, 'Insumo "${criado.descricao}" cadastrado.');
  }

  Future<void> _comprar(Insumo insumo) async {
    final atualizado =
        await abrirRegistroDeCompra(context, widget.viewModel, insumo);

    if (atualizado == null || !mounted) return;

    mostrarSucesso(context, 'Compra de "${insumo.descricao}" registrada.');
  }

  void _abrirDetalhe(Insumo insumo) {
    final id = insumo.id;
    if (id == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesInsumoView(
          idInsumo: id,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppCores.fundo,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cadastrar,
        backgroundColor: AppCores.verdePrimario,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Insumo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final vm = widget.viewModel;

          return CorpoComEstado(
            isLoading: vm.isCarregandoInsumos,
            mensagemErro: vm.insumos.isEmpty ? vm.mensagemErroInsumos : null,
            vazio: vm.insumos.isEmpty,
            aoTentarNovamente: vm.carregarInsumos,
            construirVazio: (context) => EstadoVazio(
              icone: Icons.inventory_2_outlined,
              mensagem:
                  'Nenhum insumo no armazém.\nCadastre o primeiro para começar a controlar o estoque.',
              acao: SizedBox(
                width: 220,
                child: CustomButton(
                  text: 'Cadastrar insumo',
                  onPressed: _cadastrar,
                ),
              ),
            ),
            construirConteudo: (context) => _construirLista(vm.insumos),
          );
        },
      ),
    );
  }

  Widget _construirLista(List<Insumo> todos) {
    final filtrados = _filtrar(todos);

    return Column(
      children: [
        const SizedBox(height: 16),
        CampoBuscaModal(
          controller: _buscaController,
          dica: 'Buscar insumo por nome',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtrados.isEmpty
              ? EstadoVazio(
                  icone: Icons.search_off,
                  mensagem: 'Nenhum insumo encontrado com "$_termoBusca".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  itemCount: filtrados.length,
                  itemBuilder: (context, indice) {
                    final insumo = filtrados[indice];

                    return InsumoCard(
                      insumo: insumo,
                      onTap: () => _abrirDetalhe(insumo),
                      aoRegistrarCompra: () => _comprar(insumo),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
