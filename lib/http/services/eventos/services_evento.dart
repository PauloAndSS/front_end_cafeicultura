import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:http/http.dart' as http;

/// Atividades de **todos** os módulos de uma propriedade.
///
/// É a rota que o calendário da home consome. Os services por tipo
/// (`ServicesTratoCultural` e os que vierem) continuam existindo para as abas
/// de atividade, que precisam do model concreto e das operações de escrita
/// específicas do módulo; aqui ficam a leitura da união e as operações que
/// valem para qualquer atividade, independente de módulo — hoje, a exclusão.
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

  /// Exclui uma atividade de **qualquer** módulo.
  ///
  /// Diferente dos `excluir` de talhão e pessoa, nenhum status recebe mensagem
  /// fabricada aqui: quem sabe se a atividade pode ou não sair é o backend, e
  /// `tratarErroRequisicao` já entrega ao usuário o motivo que ele mandou. Um
  /// `403 → 'não pode ser excluída porque X'` escrito neste arquivo seria regra
  /// de negócio duplicada, e desatualizada na primeira mudança do servidor.
  Future<bool> excluir(int idEvento) async {
    try {
      final response = await http.delete(
        Uri.parse('$url/$idEvento'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao excluir a atividade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Falha na comunicação ao excluir a atividade. Tente novamente mais tarde.',
      );
    }
  }
}
