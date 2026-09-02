import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';
import 'package:http/http.dart' as http;

class ServicesNotificacao extends BaseService {
  @override
  String get recurso => 'notificacoes';

  Future<List<Notificacao>> buscarDaPropriedade(int idPropriedade) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedades/$idPropriedade'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Notificacao.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar as notificações da propriedade.',
      acao: 'buscar as notificações',
    );
  }

  Future<List<Notificacao>> buscarNaoLidasDaPropriedade(int idPropriedade) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('nao-lidas/propriedades/$idPropriedade'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Notificacao.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar as notificações não lidas da propriedade.',
      acao: 'buscar as notificações não lidas',
    );
  }

  Future<bool> marcarComoLidas(List<int> ids) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('lida'),
        headers: defaultHeaders,
        body: jsonEncode({'idsNotificacoes': ids}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao marcar as notificações como lidas.',
      acao: 'marcar as notificações como lidas',
    );
  }
}
