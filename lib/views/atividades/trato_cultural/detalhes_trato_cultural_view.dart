import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/detalhes_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/detalhes_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/selecionar_insumos_modal.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
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
    final idProprietario = context.read<SessionViewModel>().idUsuario;

    if (idProprietario == null) {
      mostrarErro(context, 'Sessão expirada. Entre novamente para alterar os insumos.');
      return;
    }

    final escolhidos = await mostrarSelecaoInsumos(
      context: context,
      viewModel: _viewModel,
      selecionadosAtuais: _viewModel.trato.insumosUtilizados,
      idProprietario: idProprietario,
    );

    if (escolhidos == null || !mounted) return;

    final sucesso = await _viewModel.alterarInsumos(escolhidos);

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Insumos atualizados com sucesso!');
    } else {
      mostrarErro(context, _viewModel.mensagemErro ?? 'Erro ao alterar os insumos.');
    }
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
        SecaoEditavel(
          titulo: 'Insumos utilizados',
          conteudo: ChipsLista(
            rotulos: trato.insumosUtilizados
                .map((insumo) => insumo.descricaoComQuantidade)
                .toList(),
            textoVazio: 'Nenhum insumo lançado',
          ),
          onEditar: editavel ? _editarInsumos : null,
        ),
      ],
    );
  }
}
