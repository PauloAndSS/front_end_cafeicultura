import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento_base.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

export 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento_base.dart';

abstract class ServicesEventoAgricolaBase<T extends EventoAgricola>
    extends ServicesEventoBase<T> {
  Future<ResultadoPaginadoDTO<T>> buscarPorTalhao(
    int idPropriedade,
    int idTalhao, {
    required int pagina,
    required StatusEvento status,
  }) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(
        rota('propriedade/$idPropriedade/talhao/$idTalhao', {
          'pagina': '$pagina',
          'status': status.codigoApi,
        }),
      ),
      aoSucesso: (resposta) => ResultadoPaginadoDTO.deEnvelopePaginado(
        extrairDadosPaginados(resposta.bodyBytes),
        chaveDaLista,
        fromJson,
      ),
      aoListaVazia: () => paginaVazia(pagina),
      erroMsg: 'Erro ao buscar $rotuloPlural do talhão.',
      acao: 'buscar $rotuloPlural do talhão',
    );
  }
}
