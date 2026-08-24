import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/formulario_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/insumos/selecionar_insumos_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_multiplo_atividade.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';

class CadastrarTratoCulturalView extends StatefulWidget {
  final DateTime? dataInicial;

  const CadastrarTratoCulturalView({super.key, this.dataInicial});

  @override
  State<CadastrarTratoCulturalView> createState() =>
      _CadastrarTratoCulturalViewState();
}

class _CadastrarTratoCulturalViewState
    extends State<CadastrarTratoCulturalView> {
  final _viewModel = CadastrarTratoCulturalViewModel();

  TipoTrato? _tipoTratoSelecionado;
  List<InsumoUtilizado> _insumosSelecionados = [];

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormularioAtividadeView(
      viewModel: _viewModel,
      dataInicial: widget.dataInicial,
      titulo: 'Novo Trato Cultural',
      rotuloBotaoSalvar: 'Salvar Trato Cultural',
      mensagemSucesso: 'Trato cultural cadastrado com sucesso!',
      ajudaDataInicio: 'Data de início do trato cultural',
      ajudaDataFim: 'Data de término do trato cultural',
      dicaDataFim: 'Trato em andamento',
      mensagemSemTalhoes:
          'Nenhum talhão cadastrado nesta propriedade. Cadastre um talhão antes de lançar um trato cultural.',
      mensagemSemSafras:
          'Nenhuma safra cadastrada nesta propriedade. Abra uma safra antes de lançar um trato cultural.',
      mensagemSemJanela:
          'Nenhum período com talhão e safra abertos ao mesmo tempo. Confira as datas dos talhões e das safras antes de lançar um trato cultural.',
      camposEspecificosPreenchidos:
          _tipoTratoSelecionado != null || _insumosSelecionados.isNotEmpty,
      construirCamposEspecificos: _construirSeletorTipoTrato,
      construirCamposFinais: _construirSeletorInsumos,
      aoSalvar: (dados) => _viewModel.submeterFormulario(
        dados: dados,
        tipoTrato: _tipoTratoSelecionado!,
        insumosUtilizados: _insumosSelecionados,
        idSafra: dados.idSafra,
      ),
    );
  }

  Widget _construirSeletorTipoTrato(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        construirRotuloAtividade('Tipo de trato'),
        DropdownButtonFormField<TipoTrato>(
          initialValue: _tipoTratoSelecionado,
          isExpanded: true,
          decoration: decoracaoSeletorAtividade(),
          hint: const Text(
            'Selecione o tipo',
            style: TextStyle(color: Colors.black26, fontSize: 14),
          ),
          items: _viewModel.tiposTrato.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(tipo.descricao, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (valor) => setState(() => _tipoTratoSelecionado = valor),
          validator: (valor) => valor == null ? 'Obrigatório' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _construirSeletorInsumos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        construirRotuloAtividade('Insumos utilizados'),
        SeletorMultiploAtividade<InsumoUtilizado>(
          icone: Icons.inventory_2_outlined,
          rotuloVazio: 'Selecionar insumos',
          selecionados: _insumosSelecionados,
          rotuloItem: (insumo) => insumo.descricaoComQuantidade,
          aoAbrir: _abrirSelecaoInsumos,
          aoRemover: (insumo) => setState(() {
            _insumosSelecionados = _insumosSelecionados
                .where((atual) => atual.idInsumo != insumo.idInsumo)
                .toList();
          }),
        ),
      ],
    );
  }

  Future<void> _abrirSelecaoInsumos() async {
    final idProprietario = context.read<SessionViewModel>().idUsuario;

    if (idProprietario == null) {
      mostrarErro(context, 'Sessão expirada. Entre novamente para cadastrar insumos.');
      return;
    }

    final escolhidos = await mostrarSelecaoInsumos(
      context: context,
      viewModel: _viewModel,
      selecionadosAtuais: _insumosSelecionados,
      idProprietario: idProprietario,
    );

    if (escolhidos == null || !mounted) return;

    setState(() => _insumosSelecionados = escolhidos);
  }
}
