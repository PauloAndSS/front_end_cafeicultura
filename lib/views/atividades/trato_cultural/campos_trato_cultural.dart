import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/selecionar_insumos_modal.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo('Tipo de trato'),
        DropdownButtonFormField<TipoTrato>(
          initialValue: tipoTratoSelecionado,
          isExpanded: true,
          decoration: decoracaoDeSeletor(),
          hint: const Text(
            'Selecione o tipo',
            style: TextStyle(color: Colors.black26, fontSize: 14),
          ),
          items: viewModelDoTrato.tiposTrato.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(tipo.descricao, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (valor) => setState(() => tipoTratoSelecionado = valor),
          validator: (valor) => valor == null ? 'Obrigatório' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget construirSeletorInsumos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo('Insumos utilizados'),
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
