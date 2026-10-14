import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesSafra extends BaseService {
  @override
  String get recurso => 'safras';

  Future<bool> cadastrar({
    required int idPropriedade,
    DateTime? dataInicio,
  }) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(
        url,
        corpo: {
          'idPropriedade': idPropriedade,
          'dataInicio': dataParaJson(dataInicio ?? DateTime.now()),
        },
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar safra.',
      acao: 'cadastrar safra',
    );
  }

  Future<List<Safra>> buscarPorPropriedade(int idPropriedade) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(
        rota('propriedade/$idPropriedade/safras/todas'),
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
      requisicao: RequisicaoHttp.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/eventos'),
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
      requisicao: RequisicaoHttp.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/relatorio-financeiro'),
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
      requisicao: RequisicaoHttp.get(
        rota('propriedade/$idPropriedade/safra/$idSafra/talhao/$idTalhao/eventos'),
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
      requisicao: RequisicaoHttp.patch(
        rota('$idSafra/finalizar'),
        corpo: {'dataFim': dataParaJson(dataFim ?? DateTime.now())},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao encerrar safra.',
      acao: 'encerrar safra',
    );
  }

  Future<bool> editarDataInicio(int idSafra, DateTime dataInicio) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(
        rota('$idSafra/data-inicio'),
        corpo: {'dataInicio': dataParaJson(dataInicio)},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao alterar a data de início da safra.',
      acao: 'alterar a data de início da safra',
    );
  }

  Future<bool> reativar(int idSafra) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(rota('$idSafra/reativar')),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao reativar safra.',
      acao: 'reativar safra',
    );
  }
}
