import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo_utilizado.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_insumos_mixin.dart';

class DetalhesTratoCulturalViewModel
    extends DetalhesAtividadeViewModel<TratoCultural>
    with CarregarInsumosMixin {
  DetalhesTratoCulturalViewModel(super.trato);

  final _tratoService = ServicesTratoCultural();

  /// Cópia local do trato, atualizada a cada PATCH bem-sucedido.
  TratoCultural get trato => atividade;

  @override
  String get rotuloAtividade => 'o trato cultural';

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
  TratoCultural copiarComum(
    TratoCultural atual, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    List<Pessoa>? responsaveis,
  }) {
    return atual.copyWith(
      dataInicio: dataInicio,
      dataFim: dataFim,
      descricao: descricao,
      responsaveis: responsaveis,
    );
  }

  /// Recebe o conjunto final de insumos — como em `alterarResponsaveis`, o
  /// endpoint substitui a lista inteira.
  ///
  /// Fica aqui, e não na base, porque insumo é específico de trato cultural.
  Future<bool> alterarInsumos(List<InsumoUtilizado> escolhidos) {
    return executar(
      chamada: () => _tratoService.alterarInsumos(atividade.id!, escolhidos),
      aplicar: () =>
          atividade = atividade.copyWith(insumosUtilizados: escolhidos),
      erroInterno: 'Ocorreu um erro interno ao alterar os insumos.',
    );
  }
}
