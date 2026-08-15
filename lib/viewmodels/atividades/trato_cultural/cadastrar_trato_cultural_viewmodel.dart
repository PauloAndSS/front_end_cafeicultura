import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/dados_formulario_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/tipo_trato.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo_utilizado.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/cadastrar_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_insumos_mixin.dart';

class CadastrarTratoCulturalViewModel extends CadastrarAtividadeViewModel
    with CarregarInsumosMixin {

  final _tratoService = ServicesTratoCultural();

  List<TipoTrato> _tiposTrato = [];
  List<TipoTrato> get tiposTrato => _tiposTrato;

  @override
  String get atividadeIndefinida => 'um trato cultural';

  /// O catálogo de tipos é o que distingue este formulário dos demais.
  @override
  Future<void> carregarDadosEspecificos(int idPropriedade) async {
    _tiposTrato = await _tratoService.buscarTiposTrato();
  }

  Future<bool> submeterFormulario({
    required DadosFormularioAtividade dados,
    required TipoTrato tipoTrato,
    required List<InsumoUtilizado> insumosUtilizados,
    required int idSafra, // 👈 Recebe a safra atual dinamicamente aqui
  }) {
    return executarCadastro(
      chamada: () {
        final trato = TratoCultural(
          idTalhao: dados.idTalhao,
          tipoTrato: tipoTrato,
          dataInicio: dados.dataInicio,
          dataFim: dados.dataFim,
          descricao: dados.descricao?.trim(),
          idSafra: idSafra, 
          responsaveis: dados.responsaveis,
          insumosUtilizados: insumosUtilizados,
        );

        return _tratoService.cadastrar(trato);
      },
      erroInterno: 'Ocorreu um erro interno ao cadastrar trato cultural.',
    );
  }
}