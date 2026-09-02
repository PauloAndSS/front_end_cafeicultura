import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/detalhes_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/detalhes_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/selecionar_insumos_modal.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/secao_lista_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';

class DetalhesTratoCulturalView extends StatefulWidget {
  final TratoCultural trato;

  final Talhao? talhao;

  const DetalhesTratoCulturalView({
    super.key,
    required this.trato,
    required this.talhao,
  });

  @override
  State<DetalhesTratoCulturalView> createState() =>
      _DetalhesTratoCulturalViewState();
}

class _DetalhesTratoCulturalViewState extends State<DetalhesTratoCulturalView> {
  late final _viewModel = DetalhesTratoCulturalViewModel(widget.trato);

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _editarInsumos() async {
    final idPropriedade =
        context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarAviso(
        context,
        'Selecione uma propriedade antes de alterar os insumos.',
      );
      return;
    }

    final fornecedores = await _viewModel.carregarFornecedores();

    if (!mounted) return;

    final escolhidos = await mostrarSelecaoInsumos(
      context: context,
      viewModel: _viewModel,
      catalogoDePessoas: _viewModel,
      selecionadosAtuais: _viewModel.trato.insumosUtilizados,
      idPropriedade: idPropriedade,
      fornecedores: fornecedores,
    );

    if (escolhidos == null || !mounted) return;

    await _aplicarInsumos(escolhidos);
  }

  Future<void> _removerInsumo(InsumoUtilizado insumo) {
    return _aplicarInsumos(
      _viewModel.trato.insumosUtilizados
          .where((atual) => atual.idInsumo != insumo.idInsumo)
          .toList(),
    );
  }

  Future<void> _aplicarInsumos(List<InsumoUtilizado> escolhidos) async {
    final sucesso = await _viewModel.alterarInsumos(escolhidos);

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Insumos atualizados com sucesso!');
    } else {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao alterar os insumos.');
    }
  }

  Widget _construirSecaoInsumos(TratoCultural trato, bool editavel) {
    return SecaoListaAtividade<InsumoUtilizado>(
      titulo: 'Insumos utilizados',
      icone: Icons.inventory_2_outlined,
      rotuloVazio: 'Selecionar insumos',
      textoVazio: 'Nenhum insumo lançado',
      rotuloContagem: trato.insumosUtilizados.contagem,
      itens: trato.insumosUtilizados,
      rotuloItem: (insumo) => insumo.descricaoComQuantidade,
      aoAbrir: editavel ? _editarInsumos : null,
      aoRemover: _removerInsumo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DetalhesAtividadeView<TratoCultural>(
      viewModel: _viewModel,
      talhao: widget.talhao,
      tituloCartao: 'Informações do Trato',
      rotuloBotaoConfirmar: 'Confirmar Trato',
      tituloTelaConfirmar: 'Confirmar Trato Cultural',
      ajudaDataInicio: 'Data de início do trato cultural',
      ajudaDataFim: 'Data de término do trato cultural',
      mensagemSucessoConfirmar: 'Trato cultural confirmado com sucesso!',
      mensagemJaFinalizada:
          'Este trato cultural já foi finalizado e não pode mais ser modificado.',
      construirLinhasExtras: (context, trato, editavel) => [
        LinhaInfo(rotulo: 'Tipo:', valor: trato.tipoTrato.descricao),
      ],
      construirSecoesExtras: (context, trato, editavel) => [
        const Divider(height: 32, color: AppCores.borda),
        _construirSecaoInsumos(trato, editavel),
      ],
      secaoExtraVazia: (trato) => trato.insumosUtilizados.isEmpty,
      construirSecaoExtraNaConfirmacao: (context, trato) =>
          _construirSecaoInsumos(trato, !_viewModel.isLoading),
    );
  }
}
