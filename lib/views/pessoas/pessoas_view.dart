import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/pessoas_da_categoria_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_pessoa_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/pessoas_categoria_tab_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_app_bar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';

class PessoasView extends StatefulWidget {
  const PessoasView({super.key});

  @override
  State<PessoasView> createState() => _PessoasViewState();
}

class _PessoasViewState extends State<PessoasView>
    with SingleTickerProviderStateMixin {
  static const List<TipoPapel> _categorias = TipoPapel.values;

  late final TabController _tabController = TabController(
    length: _categorias.length,
    vsync: this,
  )..addListener(_aoTrocarDeAba);

  late final Map<TipoPapel, PessoasDaCategoriaViewModel> _viewModels = {
    for (final papel in _categorias) papel: PessoasDaCategoriaViewModel(papel),
  };

  TipoPapel get _papelAtivo => _categorias[_tabController.index];

  void _aoTrocarDeAba() {
    if (_tabController.indexIsChanging) return;

    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_aoTrocarDeAba);
    _tabController.dispose();

    for (final viewModel in _viewModels.values) {
      viewModel.dispose();
    }

    super.dispose();
  }

  Future<void> _abrirTelaCadastro() async {
    final papel = _papelAtivo;

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CadastrarPessoaView(papel: papel)),
    );

    if (cadastrou == true && mounted) _viewModels[papel]!.carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          BarraDeAbas(
            controller: _tabController,
            rolavel: true,
            abas: [
              for (final papel in _categorias) Tab(text: papel.tituloPlural),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final papel in _categorias)
                  PessoasCategoriaTabView(viewModel: _viewModels[papel]!),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppCores.verdeSecundario,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: _abrirTelaCadastro,
        label: Row(
          children: [
            Text(
              'Cadastrar\n${_papelAtivo.titulo}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add, color: Colors.white, size: 28),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(ocultarSelecao: true),
    );
  }
}
