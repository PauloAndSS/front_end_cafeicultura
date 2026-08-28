import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:http/http.dart' as http;

abstract class ServicesEventoBase<T extends Evento> extends BaseService {
  @protected
  T Function(Map<String, dynamic>) get fromJson;

  @protected
  String get chaveDaLista;

  @protected
  String get rotulo;

  @protected
  String get rotuloPlural;

  @protected
  String get paramInicio => 'filtroInicio';

  @protected
  String get paramFim => 'filtroFim';

  Future<bool> cadastrar(T evento) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(evento.toJson()),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar $rotulo.',
      acao: 'cadastrar $rotulo',
    );
  }

  Future<List<T>> buscarPorPeriodo(
    int idPropriedade, {
    required DateTime inicio,
    required DateTime fim,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade', {
          paramInicio: instanteParaJson(inicio),
          paramFim: instanteParaJson(fim),
        }),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairListaNomeada(resposta.bodyBytes, chaveDaLista, fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar $rotuloPlural do período.',
      acao: 'buscar $rotuloPlural',
    );
  }

  Future<ResultadoPaginadoDTO<T>> buscarPorStatus(
    int idPropriedade, {
    required StatusEvento status,
    required int pagina,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade', {
          'status': status.codigoApi,
          'pagina': '$pagina',
        }),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => ResultadoPaginadoDTO.deEnvelopePaginado(
        extrairDadosPaginados(resposta.bodyBytes),
        chaveDaLista,
        fromJson,
      ),
      aoListaVazia: () => paginaVazia(pagina),
      erroMsg: 'Erro ao buscar $rotuloPlural da propriedade.',
      acao: 'buscar $rotuloPlural',
    );
  }

  Future<bool> confirmar(
    int id, {
    required DateTime dataInicio,
    required DateTime dataFim,
  }) {
    final agora = DateTime.now();

    return alterar(
      id: id,
      subRota: 'finalizar',
      corpo: {
        'dataInicio': diaNaoFuturoParaJson(dataInicio, agora: agora),
        'dataFim': diaNaoFuturoParaJson(dataFim, agora: agora),
      },
      erroMsg: 'Erro ao confirmar $rotulo.',
      acao: 'confirmar $rotulo',
    );
  }

  Future<bool> alterarDataInicio(int id, DateTime dataInicio) {
    return alterar(
      id: id,
      subRota: 'alterarInicio',
      corpo: {'dataInicio': dataParaJson(dataInicio)},
      erroMsg: 'Erro ao alterar a data de início do $rotulo.',
      acao: 'alterar a data de início',
    );
  }

  Future<bool> alterarDescricao(int id, String descricao) {
    return alterar(
      id: id,
      subRota: 'descricao',
      corpo: {'descricao': descricao},
      erroMsg: 'Erro ao alterar a descrição do $rotulo.',
      acao: 'alterar a descrição',
    );
  }

  Future<bool> alterarResponsaveis(int id, List<int> responsaveisIds) {
    return alterar(
      id: id,
      subRota: 'responsaveis',
      corpo: {'responsaveisIds': responsaveisIds},
      erroMsg: 'Erro ao alterar os responsáveis do $rotulo.',
      acao: 'alterar os responsáveis',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      enviar: () => http.delete(rota('$id'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao excluir o $rotulo.',
      acao: 'excluir o $rotulo',
    );
  }


  @protected
  Future<bool> alterar({
    required int id,
    required String subRota,
    required Map<String, dynamic> corpo,
    required String erroMsg,
    required String acao,
  }) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$id/$subRota'),
        headers: defaultHeaders,
        body: jsonEncode(corpo),
      ),
      aoSucesso: (_) => true,
      erroMsg: erroMsg,
      acao: acao,
    );
  }

  @protected
  ResultadoPaginadoDTO<T> paginaVazia(int pagina) => ResultadoPaginadoDTO(
        data: const [],
        total: 0,
        pagina: pagina,
        totalPaginas: pagina,
      );
}
