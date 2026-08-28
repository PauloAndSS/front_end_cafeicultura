import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_paginada_viewmodel.dart';

class TratosCulturaisDoTalhaoViewModel
    extends ListaAtividadesDoTalhaoPaginadaViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  Future<ResultadoPaginadoDTO<TratoCultural>> buscarNoTalhao(
    int idPropriedade,
    int idTalhao,
    StatusEvento status,
    int pagina,
  ) {
    return _tratoService.buscarPorTalhao(
      idPropriedade,
      idTalhao,
      status: status,
      pagina: pagina,
    );
  }
}
