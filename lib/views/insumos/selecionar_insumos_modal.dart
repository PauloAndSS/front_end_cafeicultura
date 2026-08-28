import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/cadastrar_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/quantidade_insumo_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';

Future<List<InsumoUtilizado>?> mostrarSelecaoInsumos({
  required BuildContext context,
  required CarregarInsumosMixin viewModel,
  required CarregarPessoasMixin catalogoDePessoas,
  required List<InsumoUtilizado> selecionadosAtuais,
  required int idProprietario,
  required int idPropriedade,
  List<Pessoa> fornecedores = const [],
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
      catalogoDePessoas: catalogoDePessoas,
      selecionadosAtuais: selecionadosAtuais,
      idProprietario: idProprietario,
      idPropriedade: idPropriedade,
      fornecedores: fornecedores,
    ),
  );
}

class _SelecionarInsumosSheet extends StatefulWidget {
  final CarregarInsumosMixin viewModel;
  final CarregarPessoasMixin catalogoDePessoas;
  final List<InsumoUtilizado> selecionadosAtuais;
  final int idProprietario;
  final int idPropriedade;
  final List<Pessoa> fornecedores;

  const _SelecionarInsumosSheet({
    required this.viewModel,
    required this.catalogoDePessoas,
    required this.selecionadosAtuais,
    required this.idProprietario,
    required this.idPropriedade,
    required this.fornecedores,
  });

  @override
  State<_SelecionarInsumosSheet> createState() =>
      _SelecionarInsumosSheetState();
}

class _SelecionarInsumosSheetState extends State<_SelecionarInsumosSheet> {
  final _buscaController = TextEditingController();

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
      catalogoDePessoas: widget.catalogoDePessoas,
      idProprietario: widget.idProprietario,
      idPropriedade: widget.idPropriedade,
      fornecedores: widget.fornecedores,
    );

    if (criado == null || !mounted) return;

    mostrarSucesso(context, 'Insumo "${criado.descricao}" cadastrado.');

    await _marcar(criado);
  }

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
        insumo: insumo,
        qtdUsada: quantidade,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final alturaSheet = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: alturaSheet,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const CabecalhoModal(titulo: 'Insumos utilizados'),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, child) => _construirConteudo(),
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

  Widget _construirConteudo() {
    final temCatalogo = widget.viewModel.insumos.isNotEmpty;

    return Column(
      children: [
        _construirAcaoCadastrar(),
        if (temCatalogo) CampoBuscaModal(controller: _buscaController, dica: 'Buscar por descrição'),
        Expanded(child: _construirCorpo()),
      ],
    );
  }

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
            border: Border.all(color: AppCores.verdePrimario),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppCores.verdePrimario),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cadastrar novo insumo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppCores.verdePrimario,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCorpo() {
    final vm = widget.viewModel;

    if (vm.isCarregandoInsumos) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.verdePrimario),
      );
    }

    if (vm.mensagemErroInsumos != null && vm.insumos.isEmpty) {
      return EstadoVazio(
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
      return EstadoVazio(
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
      return EstadoVazio(
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

        return ListTile(
          leading: Checkbox(
            value: selecionado != null,
            activeColor: AppCores.verdePrimario,
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
}
