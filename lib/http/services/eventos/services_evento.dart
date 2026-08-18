import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:http/http.dart' as http;

/// Atividades de **todos** os módulos de uma propriedade.
///
/// É a rota que o calendário da home consome, e é só isso que mora aqui: a
/// leitura da união dos módulos. As operações de escrita ficam nos services por
/// tipo (`ServicesTratoCultural` e os que vierem), que têm o model concreto e a
/// rota própria de cada uma — inclusive a exclusão, que já foi genérica e hoje
/// é `DELETE /tratosculturais/{id}` e companhia.
class ServicesEvento extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/eventos');

  /// Todas as atividades da propriedade na janela [dataInicio]–[dataFim].
  ///
  /// **A rota não pagina.** Ela devolve a janela inteira de uma vez, e é por
  /// isso que o retorno é uma `List` e não um `ResultadoPaginadoDTO`: os
  /// contadores não vêm no corpo, e fabricar um DTO com `totalPaginas: 1`
  /// sugeriria uma paginação que não existe.
  Future<List<EventoAgricola>> buscarPorPropriedade(
    int idPropriedade, {
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final uri = Uri.parse('$url/propriedade/$idPropriedade').replace(
        queryParameters: {
          'dataInicio': dataInicio.toUtc().toIso8601String(),
          'dataFim': dataFim.toUtc().toIso8601String(),
        },
      );

      final response = await http.get(uri, headers: defaultHeaders);

      if (response.statusCode == 200) {
        return extrairListaNomeada(
          response.bodyBytes,
          'eventos',
          EventoFactory.fromJson,
        );
      } else if (response.statusCode == 404) {
        // Guarda defensiva, espelhando a de `ServicesTratoCultural`: lá o
        // backend responde 404 quando não há nada na janela. Para o calendário
        // isso não é falha — é mês vazio, e a grade precisa ser desenhada do
        // mesmo jeito.
        return const [];
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar as atividades da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao buscar as atividades. Tente novamente mais tarde.',
      );
    }
  }
}
