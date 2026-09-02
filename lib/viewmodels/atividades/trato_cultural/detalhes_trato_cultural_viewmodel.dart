import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';

class DetalhesTratoCulturalViewModel
    extends DetalhesAtividadeViewModel<TratoCultural>
    with CarregarInsumosMixin {
  DetalhesTratoCulturalViewModel(super.trato);

  final _tratoService = ServicesTratoCultural();

  TratoCultural get trato => atividade;

  @override
  ChamadaConfirmar? get chamadaConfirmar => _tratoService.confirmar;

  @override
  ChamadaData? get chamadaAlterarDataInicio => _tratoService.alterarDataInicio;

  @override
  ChamadaTexto? get chamadaAlterarDescricao => _tratoService.alterarDescricao;

  @override
  ChamadaIds? get chamadaAlterarResponsaveis =>
      _tratoService.alterarResponsaveis;

  @override
  ChamadaExcluir? get chamadaExcluir => _tratoService.excluir;

  @override
  TratoCultural copiarComum(
    TratoCultural atual, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    List<Pessoa>? responsaveis,
    List<TransacaoFinanceira>? transacoesFinanceiras,
  }) {
    return atual.copyWith(
      dataInicio: dataInicio,
      dataFim: dataFim,
      descricao: descricao,
      responsaveis: responsaveis,
      transacoesFinanceiras: transacoesFinanceiras,
    );
  }

  Future<bool> alterarInsumos(List<InsumoUtilizado> escolhidos) {
    return executarEdicao(
      chamada: () => _tratoService.alterarInsumos(atividade.id!, escolhidos),
      aplicar: () {
        atividade = atividade.copyWith(insumosUtilizados: escolhidos);
        marcarInsumosDesatualizados();
      },
    );
  }
}
