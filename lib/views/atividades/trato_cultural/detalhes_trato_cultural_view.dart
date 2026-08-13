import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/detalhes_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/detalhes_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/selecionar_insumos_modal.dart';
import 'package:provider/provider.dart';

/// Detalhes de um trato cultural.
///
/// Tudo o que é comum a qualquer atividade — confirmar, datas, descrição,
/// responsáveis, status — vem de [DetalhesAtividadeView]. Aqui sobram a linha
/// do tipo e a seção de insumos.
class DetalhesTratoCulturalView extends StatefulWidget {
  final TratoCultural trato;
  final String nomeTalhao;

  const DetalhesTratoCulturalView({
    super.key,
    required this.trato,
    required this.nomeTalhao,
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

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: const Color(0xFFD32F2F)),
    );
  }

  Future<void> _editarInsumos() async {
    // O id do proprietário sai da sessão aqui, na View: ViewModel não conhece
    // BuildContext.
    final idProprietario = context.read<SessionViewModel>().idUsuario;

    if (idProprietario == null) {
      _mostrarErro('Sessão expirada. Entre novamente para alterar os insumos.');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insumos atualizados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _mostrarErro(_viewModel.mensagemErro ?? 'Erro ao alterar os insumos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetalhesAtividadeView<TratoCultural>(
      viewModel: _viewModel,
      nomeTalhao: widget.nomeTalhao,
      tituloCartao: 'Informações do Trato',
      rotuloBotaoConfirmar: 'Confirmar Trato',
      tituloTelaConfirmar: 'Confirmar Trato Cultural',
      ajudaDataInicio: 'Data de início do trato cultural',
      ajudaDataFim: 'Data de término do trato cultural',
      mensagemSucessoConfirmar: 'Trato cultural confirmado com sucesso!',
      mensagemJaFinalizada:
          'Este trato cultural já foi finalizado e não pode mais ser modificado.',
      construirLinhasExtras: (context, trato, editavel) => [
        LinhaInfoAtividade(rotulo: 'Tipo:', valor: trato.tipoTrato.descricao),
      ],
      construirSecoesExtras: (context, trato, editavel) => [
        const Divider(height: 32, color: Color(0xFFE0E0E0)),
        SecaoEditavelAtividade(
          titulo: 'Insumos utilizados',
          conteudo: ChipsAtividade(
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
