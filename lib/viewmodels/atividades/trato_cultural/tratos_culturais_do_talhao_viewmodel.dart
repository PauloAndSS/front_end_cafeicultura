import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_viewmodel.dart';

/// Tratos culturais de um único talhão.
///
/// Separado de [TratosCulturaisViewModel] porque aquele resolve os nomes de
/// todos os talhões da propriedade para montar os cards — aqui o nome já vem
/// pronto de quem abriu a tela do talhão, então essa paginação extra seria
/// desperdício.
class TratosCulturaisDoTalhaoViewModel
    extends ListaAtividadesDoTalhaoViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  String get erroInternoAoCarregar =>
      'Ocorreu um erro interno ao carregar as atividades do talhão.';

  @override
  Future<List<TratoCultural>> buscarNoTalhao(
    int idPropriedade,
    int idTalhao,
  ) {
    return _tratoService.buscarPorTalhao(idPropriedade, idTalhao);
  }
}
