import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/selecionar_insumos_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:provider/provider.dart';

mixin CamposTratoCulturalMixin<T extends StatefulWidget> on State<T> {
  CadastrarTratoCulturalViewModel get viewModelDoTrato;

  TipoTrato? tipoTratoSelecionado;

  List<InsumoUtilizado> insumosSelecionados = [];

  bool get camposDoTratoPreenchidos =>
      tipoTratoSelecionado != null || insumosSelecionados.isNotEmpty;

  Widget construirSeletorTipoTrato(BuildContext context) {
    return CampoSuspenso<TipoTrato>(
      rotulo: 'Tipo de trato',
      valor: tipoTratoSelecionado,
      itens: viewModelDoTrato.tiposTrato,
      rotuloItem: (tipo) => tipo.descricao,
      dica: 'Selecione o tipo',
      aoSelecionar: (valor) => setState(() => tipoTratoSelecionado = valor),
      validador: (valor) => valor == null ? 'Obrigatório' : null,
    );
  }

  Widget construirSeletorInsumos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, 'Insumos utilizados', opcional: true),
        SeletorMultiploAtividade<InsumoUtilizado>(
          icone: Icons.inventory_2_outlined,
          rotuloVazio: 'Selecionar insumos',
          selecionados: insumosSelecionados,
          rotuloItem: (insumo) => insumo.descricaoComQuantidade,
          rotuloContagem: insumosSelecionados.contagem,
          aoAbrir: _abrirSelecaoInsumos,
          aoRemover: (insumo) => setState(() {
            insumosSelecionados = insumosSelecionados
                .where((atual) => atual.idInsumo != insumo.idInsumo)
                .toList();
          }),
        ),
      ],
    );
  }

  Future<void> _abrirSelecaoInsumos() async {
    final idPropriedade =
        context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarAviso(
        context,
        'Selecione uma propriedade antes de cadastrar insumos.',
      );
      return;
    }

    final fornecedores = await viewModelDoTrato.carregarFornecedores();

    if (!mounted) return;

    final escolhidos = await mostrarSelecaoInsumos(
      context: context,
      viewModel: viewModelDoTrato,
      catalogoDePessoas: viewModelDoTrato,
      selecionadosAtuais: insumosSelecionados,
      idPropriedade: idPropriedade,
      fornecedores: fornecedores,
    );

    if (escolhidos == null || !mounted) return;

    setState(() => insumosSelecionados = escolhidos);
  }
}
