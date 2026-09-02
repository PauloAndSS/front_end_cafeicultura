import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/cadastrar_trato_cultural_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/dados_formulario_atividade.dart';

class EditarTratoCulturalViewModel extends CadastrarTratoCulturalViewModel {
  EditarTratoCulturalViewModel(this.idTrato);

  final int idTrato;

  final _service = ServicesTratoCultural();

  TratoCultural? _tratoAtualizado;
  TratoCultural? get tratoAtualizado => _tratoAtualizado;

  @override
  String get atividadeIndefinida => 'as alterações do trato cultural';

  Future<bool> submeterEdicao({
    required DadosFormularioAtividade dados,
    required TipoTrato tipoTrato,
    required List<InsumoUtilizado> insumosUtilizados,
    required int idSafra,
  }) {
    return executarCadastro(
      chamada: () async {
        final trato = TratoCultural(
          idTalhao: dados.idTalhao,
          tipoTrato: tipoTrato,
          dataInicio: dados.dataInicio,
          dataFim: dados.dataFim,
          descricao: dados.descricao?.trim(),
          idSafra: idSafra,
          responsaveis: dados.responsaveis,
          transacoesFinanceiras: dados.despesas,
          insumosUtilizados: insumosUtilizados,
        );

        _tratoAtualizado = await _service.editar(idTrato, trato);

        return true;
      },
    );
  }
}
