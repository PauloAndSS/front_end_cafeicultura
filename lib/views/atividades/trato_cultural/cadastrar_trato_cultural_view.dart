import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/formulario_atividade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/campos_trato_cultural.dart';

class CadastrarTratoCulturalView extends StatefulWidget {
  final DateTime? dataInicial;

  const CadastrarTratoCulturalView({super.key, this.dataInicial});

  @override
  State<CadastrarTratoCulturalView> createState() =>
      _CadastrarTratoCulturalViewState();
}

class _CadastrarTratoCulturalViewState extends State<CadastrarTratoCulturalView>
    with CamposTratoCulturalMixin<CadastrarTratoCulturalView> {
  final _viewModel = CadastrarTratoCulturalViewModel();

  @override
  CadastrarTratoCulturalViewModel get viewModelDoTrato => _viewModel;

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
      camposEspecificosPreenchidos: camposDoTratoPreenchidos,
      construirCamposEspecificos: construirSeletorTipoTrato,
      construirCamposFinais: construirSeletorInsumos,
      aoSalvar: (dados) => _viewModel.submeterFormulario(
        dados: dados,
        tipoTrato: tipoTratoSelecionado!,
        insumosUtilizados: insumosSelecionados,
        idSafra: dados.idSafra,
      ),
    );
  }
}
