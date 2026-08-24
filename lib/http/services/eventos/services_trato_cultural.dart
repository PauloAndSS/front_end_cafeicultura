import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento_agricola_base.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:http/http.dart' as http;

class ServicesTratoCultural extends ServicesEventoAgricolaBase<TratoCultural> {
  @override
  String get recurso => 'tratosculturais';

  @override
  String get chaveDaLista => 'tratos';

  @override
  String get rotulo => 'trato cultural';

  @override
  String get rotuloPlural => 'tratos culturais';

  @override
  TratoCultural Function(Map<String, dynamic>) get fromJson =>
      TratoCultural.fromJson;

  Future<List<TipoTrato>> buscarTiposTrato() {
    return executarRequisicao(
      enviar: () => http.get(rota('tipos'), headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, TipoTrato.fromJson),
      erroMsg: 'Erro ao buscar tipos de $rotulo.',
      acao: 'buscar os tipos de $rotulo',
    );
  }
  Future<bool> alterarInsumos(int idTrato, List<InsumoUtilizado> insumos) {
    return alterar(
      id: idTrato,
      subRota: 'insumos',
      corpo: {'insumos': insumos.map((insumo) => insumo.toJson()).toList()},
      erroMsg: 'Erro ao alterar os insumos do $rotulo.',
      acao: 'alterar os insumos',
    );
  }
}
