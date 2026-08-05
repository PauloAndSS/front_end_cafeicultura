import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/pessoas_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_pessoa_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/detalhes_pessoa_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';
import 'package:provider/provider.dart';

import 'package:frond_end_cafeicultura_mobile/views/widgets/pessoas_card_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/titulo_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_app_bar.dart';

class PessoasView extends StatefulWidget {
  const PessoasView({super.key});

  @override
  State<PessoasView> createState() => _PessoasViewState();
}

class _PessoasViewState extends State<PessoasView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PessoasViewModel>().carregarPessoas(recarregar: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PessoasViewModel>().carregarMaisPessoas();
    }
  }

  Future<void> _abrirTelaCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastrarPessoaView()),
    );

    if (resultado == true && mounted) {
      context.read<PessoasViewModel>().carregarPessoas(recarregar: true);
    }
  }

  List<Widget> _buildSecao(String titulo, List<dynamic> lista) {
    if (lista.isEmpty) return [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: TituloWidget(titulo: titulo),
        ),
      ),

      SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = lista[index];
          return PessoaCardWidget(
            nome: item.pessoa.nomeParaExibicao,
            funcao: _obterNomeFuncao(item),
            onTap: () async {
              final alterou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesPessoaView(papelPessoa: item),
                ),
              );
              
              if (alterou == true && mounted) {
                context.read<PessoasViewModel>().carregarPessoas(recarregar: true);
              }
            },
          );
        }, childCount: lista.length),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 32.0)),
    ];
  }

  String _obterNomeFuncao(dynamic item) {
    if (item is Funcionario) return 'Funcionário';
    if (item is Fornecedor) return 'Fornecedor';
    if (item is Cliente) return 'Cliente';
    if (item is Meeiro) return 'Meeiro';
    if (item is PrestadorDeServico) return 'Prestador de Serviço';
    return 'Não definido';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PessoasViewModel>();

    final bool todasListasVazias =
        vm.funcionarios.isEmpty &&
        vm.meeiros.isEmpty &&
        vm.fornecedores.isEmpty &&
        vm.prestadores.isEmpty &&
        vm.clientes.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const CustomAppBar(),

      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8FA67E)),
            )
          : vm.mensagemErro != null
          ? Center(
              child: Text(
                vm.mensagemErro!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : todasListasVazias
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off_outlined,
                    size: 64,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Não há pessoas cadastradas.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  ..._buildSecao('Clientes', vm.clientes),
                  ..._buildSecao('Fornecedores', vm.fornecedores),
                  ..._buildSecao('Funcionários', vm.funcionarios),
                  ..._buildSecao('Meeiros', vm.meeiros),
                  ..._buildSecao('Prestadores', vm.prestadores),
                  

                  if (vm.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF8FA67E)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8FA67E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: _abrirTelaCadastro,
        label: const Row(
          children: [
            Text(
              'Cadastrar\nPessoa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.add, color: Colors.white, size: 28),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(ocultarSelecao: true),
    );
  }
}