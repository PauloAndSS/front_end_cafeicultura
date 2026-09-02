import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/acoes_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';

class DetalhesInsumoView extends StatefulWidget {
  final int idInsumo;
  final int idPropriedade;
  final InsumosViewModel viewModel;

  const DetalhesInsumoView({
    super.key,
    required this.idInsumo,
    required this.idPropriedade,
    required this.viewModel,
  });

  @override
  State<DetalhesInsumoView> createState() => _DetalhesInsumoViewState();
}

class _DetalhesInsumoViewState extends State<DetalhesInsumoView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.abrirDetalhe(
        widget.idInsumo,
        idPropriedade: widget.idPropriedade,
      );
    });
  }

  Future<void> _comprar(Insumo insumo) async {
    final atualizado =
        await abrirRegistroDeCompra(context, widget.viewModel, insumo);

    if (atualizado == null || !mounted) return;

    mostrarSucesso(context, 'Compra de "${insumo.descricao}" registrada.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: const AppBarPadrao(titulo: 'Detalhes do Insumo'),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final vm = widget.viewModel;

          return CorpoComEstado(
            isLoading: vm.isCarregandoDetalhe,
            mensagemErro: vm.mensagemErroDetalhe,
            vazio: vm.insumoDetalhe == null,
            aoTentarNovamente: () => vm.abrirDetalhe(
              widget.idInsumo,
              idPropriedade: widget.idPropriedade,
            ),
            construirVazio: (context) => const EstadoVazio(
              icone: Icons.inventory_2_outlined,
              mensagem: 'Os dados deste insumo não estão disponíveis.',
            ),
            construirConteudo: (context) => _construirDetalhe(vm.insumoDetalhe!),
          );
        },
      ),
    );
  }

  Widget _construirDetalhe(Insumo insumo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CartaoDetalhe(
            titulo: insumo.descricao,
            conteudo: [
              LinhaInfo(rotulo: 'Descrição', valor: insumo.descricao),
              LinhaInfo(
                rotulo: 'Unidade de medida',
                valor: insumo.unidadeFormatada,
              ),
              LinhaInfo(
                rotulo: 'Saldo em estoque',
                valor: insumo.saldoFormatado,
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Registrar compra',
            onPressed: () => _comprar(insumo),
          ),
        ],
      ),
    );
  }
}
