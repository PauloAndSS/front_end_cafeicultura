import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:http/http.dart' as http;

class ServicesTalhao extends BaseService {
  @override
  String get recurso => 'talhoes';

  static const int limitePorPagina = 10;

  Future<bool> cadastrar(Talhao talhao) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(talhao.toJson()),
      ),
      aoSucesso: (_) => true,
      errosPorStatus: {
        409: 'Erro ao cadastrar talhão. Talhão com esse mesmo nome já foi cadastrado e está ativo.',
      },
      erroMsg: 'Erro ao cadastrar talhão.',
      acao: 'cadastrar talhão',
    );
  }

  Future<List<Talhao>> buscarPorPropriedade(
    int idPropriedade, {
    int pagina = 1,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/todos/$idPropriedade', {
          'pagina': '$pagina',
          'limite': '$limitePorPagina',
        }),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairListaNomeada(resposta.bodyBytes, 'talhoes', Talhao.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar talhões da propriedade.',
      acao: 'buscar talhões',
    );
  }

  Future<List<Variedade>> buscarVariedades() {
    return executarRequisicao(
      enviar: () => http.get(rota('variedades'), headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Variedade.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar variedades.',
      acao: 'buscar variedades',
    );
  }

  Future<bool> encerrar(int idTalhao, DateTime dataFim) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$idTalhao/encerrar'),
        headers: defaultHeaders,
        body: jsonEncode({'dataFim': diaNaoFuturoParaJson(dataFim)}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao encerrar talhão.',
      acao: 'encerrar talhão',
    );
  }

  Future<bool> excluir(int idTalhao) {
    return executarRequisicao(
      enviar: () => http.delete(rota('$idTalhao'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      errosPorStatus: {
        403: 'Talhão não pode ser excluído pois há atividades cadastradas nele.',
      },
      erroMsg: 'Erro ao excluir talhão.',
      acao: 'excluir talhão',
    );
  }
}
