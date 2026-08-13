import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/lista_atividades_paginada_viewmodel.dart';

/// Listagem da aba de tratos: um status por vez, uma página por vez.
///
/// O laço que percorria todas as páginas saiu daqui. Ele existia porque a aba
/// mostrava a propriedade inteira e filtrava por status na memória; agora o
/// status é query param e a rolagem pede a próxima página quando chega ao fim.
class TratosCulturaisViewModel
    extends ListaAtividadesPaginadaViewModel<TratoCultural> {
  final _tratoService = ServicesTratoCultural();

  @override
  String get erroInternoAoCarregar =>
      'Ocorreu um erro interno ao carregar tratos culturais.';

  @override
  Future<ResultadoPaginadoDTO<TratoCultural>> buscarPagina(
    int idPropriedade,
    StatusEvento status,
    int pagina,
  ) {
    return _tratoService.buscarPorStatus(
      idPropriedade,
      status: status,
      pagina: pagina,
    );
  }
}
