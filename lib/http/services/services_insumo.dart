import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:http/http.dart' as http;

class ServicesInsumo extends BaseService {
  @override
  String get recurso => 'insumos';

  Future<List<Insumo>> buscarPorPropriedade({required int idPropriedade}) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('', {'idPropriedade': '$idPropriedade'}),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Insumo.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar os insumos cadastrados.',
      acao: 'buscar os insumos',
    );
  }

  Future<Insumo?> buscarPorDescricao({
    required String descricao,
    required int idPropriedade,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('buscar', {
          'descricao': descricao,
          'idPropriedade': '$idPropriedade',
        }),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => _primeiroInsumo(resposta.bodyBytes),
      aoListaVazia: () => null,
      erroMsg: 'Erro ao localizar o insumo pela descrição.',
      acao: 'localizar o insumo pela descrição',
    );
  }

  Future<Insumo?> buscarPorId(int id, {required int idPropriedade}) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('$id', {'idPropriedade': '$idPropriedade'}),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairObjetoOuNulo(resposta.bodyBytes, Insumo.fromJson),
      erroMsg: 'Erro ao buscar o insumo.',
      acao: 'buscar o insumo',
    );
  }

  Insumo? _primeiroInsumo(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) return null;

    final bruto = _mapaDaResposta(extrairDadosResposta(bodyBytes));

    if (bruto == null || bruto['id'] == null) return null;

    return Insumo.fromJson(bruto);
  }

  Map<String, dynamic>? _mapaDaResposta(dynamic dados) {
    if (dados is Map<String, dynamic>) return dados;
    if (dados is! List) return null;

    for (final item in dados) {
      if (item is Map<String, dynamic>) return item;
    }

    return null;
  }
}
