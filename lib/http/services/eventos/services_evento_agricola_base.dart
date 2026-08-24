import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento_base.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:http/http.dart' as http;

export 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento_base.dart';

abstract class ServicesEventoAgricolaBase<T extends EventoAgricola>
    extends ServicesEventoBase<T> {
  Future<ResultadoPaginadoDTO<T>> buscarPorTalhao(
    int idPropriedade,
    int idTalhao, {
    required int pagina,
    StatusEvento? status,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade/talhao/$idTalhao', {
          'pagina': '$pagina',
          if (status != null) 'status': status.codigoApi,
        }),
        headers: defaultHeaders,
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
