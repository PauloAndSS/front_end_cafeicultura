import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/agenda_mensal_viewmodel.dart';

/// Atividades de **todos** os módulos de uma propriedade, mês a mês.
///
/// É o calendário da home. A rota de eventos gerais não pagina: devolve a janela
/// inteira de uma vez, e por isso a busca aqui é uma chamada só.
class AgendaPropriedadeViewModel extends AgendaMensalViewModel<EventoAgricola> {
  final _service = ServicesEvento();

  @override
  Future<List<EventoAgricola>> buscarNoPeriodo(
    int idPropriedade,
    DateTime inicio,
    DateTime fim,
  ) {
    return _service.buscarPorPropriedade(
      idPropriedade,
      dataInicio: inicio,
      dataFim: fim,
    );
  }
}
