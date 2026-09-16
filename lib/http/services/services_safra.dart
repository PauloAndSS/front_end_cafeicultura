import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:http/http.dart' as http;

class ServicesSafra extends BaseService {
  @override
  String get recurso => 'safras';

  Future<bool> cadastrar({
    required int idPropriedade,
    DateTime? dataInicio,
  }) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode({
          'idPropriedade': idPropriedade,
          'dataInicio': dataParaJson(dataInicio ?? DateTime.now()),
        }),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar safra.',
      acao: 'cadastrar safra',
    );
  }

  Future<List<Safra>> buscarPorPropriedade(int idPropriedade) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade/safras/todas'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) => extrairLista(resposta.bodyBytes, Safra.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar safras da propriedade.',
      acao: 'buscar safras da propriedade',
    );
  }

  Future<List<EventoAgricola>> buscarRelatorio({
    required int idPropriedade,
    required int idSafra,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/eventos'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, EventoAgricolaFactory.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar relatório da safra.',
      acao: 'buscar relatório da safra',
    );
  }

  Future<RelatorioFinanceiroSafra> buscarRelatorioFinanceiro({
    required int idPropriedade,
    required int idSafra,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/relatorio-financeiro'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, RelatorioFinanceiroSafra.fromJson),
      aoListaVazia: () => RelatorioFinanceiroSafra.vazio,
      erroMsg: 'Erro ao buscar relatório financeiro da safra.',
      acao: 'buscar relatório financeiro da safra',
    );
  }

  Future<List<EventoAgricola>> buscarRelatorioDoTalhao({
    required int idPropriedade,
    required int idSafra,
    required int idTalhao,
  }) {
    return executarRequisicao(
      enviar: () => http.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/talhao/$idTalhao/eventos'),
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, EventoAgricolaFactory.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar relatório do talhão.',
      acao: 'buscar relatório do talhão',
    );
  }

  Future<bool> encerrar(int idSafra, {DateTime? dataFim}) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$idSafra/finalizar'),
        headers: defaultHeaders,
        body: jsonEncode(
          {'dataFim': dataParaJson(dataFim ?? DateTime.now())},
        ),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao encerrar safra.',
      acao: 'encerrar safra',
    );
  }

  Future<bool> reativar(int idSafra) {
    return executarRequisicao(
      enviar: () => http.patch(rota('$idSafra/reativar'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao reativar safra.',
      acao: 'reativar safra',
    );
  }
}
