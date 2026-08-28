import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/editar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/dados_formulario_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/formulario_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/campos_trato_cultural.dart';

class EditarTratoCulturalView extends StatefulWidget {
  final TratoCultural trato;

  const EditarTratoCulturalView({super.key, required this.trato});

  @override
  State<EditarTratoCulturalView> createState() =>
      _EditarTratoCulturalViewState();
}

class _EditarTratoCulturalViewState extends State<EditarTratoCulturalView>
    with CamposTratoCulturalMixin<EditarTratoCulturalView> {
  late final _viewModel = EditarTratoCulturalViewModel(widget.trato.id!);

  @override
  CadastrarTratoCulturalViewModel get viewModelDoTrato => _viewModel;

  @override
  void initState() {
    super.initState();

    tipoTratoSelecionado = widget.trato.tipoTrato;
    insumosSelecionados = [...widget.trato.insumosUtilizados];
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  DadosFormularioAtividade get _valoresIniciais => DadosFormularioAtividade(
        idTalhao: widget.trato.idTalhao,
        idSafra: widget.trato.idSafra ?? 0,
        dataInicio: widget.trato.dataInicio,
        dataFim: widget.trato.dataFim,
        descricao: widget.trato.descricao,
        responsaveis: widget.trato.responsaveis,
        despesas: widget.trato.transacoesFinanceiras.whereType<Despesa>().toList(),
      );

  @override
  Widget build(BuildContext context) {
    return FormularioAtividadeView(
      viewModel: _viewModel,
      valoresIniciais: _valoresIniciais,
      titulo: 'Alterar Trato Cultural',
      rotuloBotaoSalvar: 'Salvar Alterações',
      mensagemSucesso: 'Trato cultural alterado com sucesso!',
      ajudaDataInicio: 'Data de início do trato cultural',
      ajudaDataFim: 'Data de término do trato cultural',
      dicaDataFim: 'Trato em andamento',
      mensagemSemTalhoes:
          'Nenhum talhão cadastrado nesta propriedade. Cadastre um talhão antes de alterar o trato cultural.',
      mensagemSemSafras:
          'Nenhuma safra cadastrada nesta propriedade. Abra uma safra antes de alterar o trato cultural.',
      mensagemSemJanela:
          'Nenhum período com talhão e safra abertos ao mesmo tempo. Confira as datas dos talhões e das safras antes de alterar o trato cultural.',
      camposEspecificosPreenchidos: camposDoTratoPreenchidos,
      construirCamposEspecificos: construirSeletorTipoTrato,
      construirCamposFinais: construirSeletorInsumos,
      aoSalvar: (dados) => _viewModel.submeterEdicao(
        dados: dados,
        tipoTrato: tipoTratoSelecionado!,
        insumosUtilizados: insumosSelecionados,
        idSafra: dados.idSafra,
      ),
    );
  }
}
