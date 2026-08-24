import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/agenda_mensal_viewmodel.dart';

class AgendaTratosCulturaisViewModel
    extends AgendaMensalViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  Future<List<TratoCultural>> buscarNoPeriodo(
    int idPropriedade,
    DateTime inicio,
    DateTime fim,
  ) {
    return _tratoService.buscarPorPeriodo(
      idPropriedade,
      inicio: inicio,
      fim: fim,
    );
  }
}
