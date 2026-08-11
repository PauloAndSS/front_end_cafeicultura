import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_viewmodel.dart';

/// Tratos culturais de toda a propriedade — a aba de tratos.
class TratosCulturaisViewModel
    extends ListaAtividadesDaPropriedadeViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  String get erroInternoAoCarregar =>
      'Ocorreu um erro interno ao carregar tratos culturais.';

  @override
  Future<List<TratoCultural>> buscarNaPropriedade(int idPropriedade) {
    return _tratoService.buscarPorPropriedade(idPropriedade);
  }
}
