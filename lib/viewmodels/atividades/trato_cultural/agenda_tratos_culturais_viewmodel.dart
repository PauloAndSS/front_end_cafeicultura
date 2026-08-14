import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/agenda_mensal_viewmodel.dart';

/// Calendário da aba de tratos: só tratos culturais, mês a mês.
///
/// Instância própria, e não uma leitura do cache de [AgendaPropriedadeViewModel]
/// da home. Compartilhar aquele cache economizaria uma requisição no mês
/// corrente e custaria um contrato de invalidação cruzada — confirmar um trato
/// por esta aba passaria a ter de invalidar o mês da home, e vice-versa. Uma
/// requisição a mais é mais barata que dado velho silencioso.
class AgendaTratosCulturaisViewModel
    extends AgendaMensalViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  String get erroInternoAoCarregar =>
      'Ocorreu um erro interno ao carregar os tratos culturais do mês.';

  @override
  Future<List<TratoCultural>> buscarNoPeriodo(
    int idPropriedade,
    DateTime inicio,
    DateTime fim,
  ) {
    return _tratoService.buscarPorPeriodo(
      idPropriedade,
      filtroInicio: inicio,
      filtroFim: fim,
    );
  }
}
