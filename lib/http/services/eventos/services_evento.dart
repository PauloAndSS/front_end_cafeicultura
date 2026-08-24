import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:http/http.dart' as http;

class ServicesEvento extends BaseService {
  @override
  String get recurso => 'eventos';


  Future<List<EventoAgricola>> buscarPorPropriedade(
    int idPropriedade, {
    required DateTime dataInicio,
    required DateTime dataFim,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade', {
          'dataInicio': instanteParaJson(dataInicio),
          'dataFim': instanteParaJson(dataFim),
        }),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => extrairListaNomeada(
        resposta.bodyBytes,
        'eventos',
        EventoAgricolaFactory.fromJson,
      ),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar as atividades da propriedade.',
      acao: 'buscar as atividades',
    );
  }
}
