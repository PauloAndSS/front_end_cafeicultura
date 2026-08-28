import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_notificacao.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';
import 'package:http/http.dart' as http;

import 'mock_http.dart';

Map<String, dynamic> notificacaoJson({
  int id = 243,
  int idEvento = 69,
  String tipoNotificacao = 'PASSADO',
  bool lida = false,
}) {
  return {
    'id': id,
    'idProprietario': 35,
    'idPropriedade': 5,
    'idEvento': idEvento,
    'tipoEvento': 'tratosculturais',
    'tipoNotificacao': tipoNotificacao,
    'dataCriacao': '2026-08-27T10:29:00.000Z',
    'lida': lida,
  };
}

void main() {
  setUp(() => BaseService.sessionCookie = null);

  group('rota e verbo', () {
    test('buscar da propriedade usa GET na rota da propriedade', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesNotificacao().buscarDaPropriedade(5),
        respostaJson([notificacaoJson()], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'GET');
      expect(enviada.url.path, endsWith('/notificacoes/propriedades/5'));
    });

    test('buscar nao lidas usa GET na rota de nao lidas', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesNotificacao().buscarNaoLidasDaPropriedade(5),
        respostaJson([notificacaoJson()], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'GET');
      expect(
        enviada.url.path,
        endsWith('/notificacoes/nao-lidas/propriedades/5'),
      );
    });

    test('marcar como lidas usa PATCH com o array de ids no corpo', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesNotificacao().marcarComoLidas([241, 242, 243]),
        respostaSemCorpo(204),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'PATCH');
      expect(enviada.url.path, endsWith('/notificacoes/lidas'));
      expect(jsonDecode(enviada.body), {
        'ids': [241, 242, 243],
      });
    });
  });

  group('leitura do payload', () {
    test('array cru vira lista de notificacoes tipadas', () async {
      final notificacoes = await comRespostaFixa(
        () => ServicesNotificacao().buscarDaPropriedade(5),
        respostaJson(
          [
            notificacaoJson(),
            notificacaoJson(id: 240, tipoNotificacao: 'FUTURO_SETE'),
          ],
          200,
        ),
      );

      expect(notificacoes, hasLength(2));
      expect(notificacoes.first.id, 243);
      expect(notificacoes.first.tipoNotificacao, TipoNotificacao.passado);
      expect(notificacoes.first.tipoEvento, TipoEventoNotificado.tratosCulturais);
      expect(notificacoes.first.lida, isFalse);
      expect(notificacoes.last.tipoNotificacao, TipoNotificacao.futuroSete);
    });

    test('tipo desconhecido nao quebra a leitura', () async {
      final notificacoes = await comRespostaFixa(
        () => ServicesNotificacao().buscarDaPropriedade(5),
        respostaJson([
          {
            ...notificacaoJson(),
            'tipoNotificacao': 'FUTURO_QUINZE',
            'tipoEvento': 'podas',
          },
        ], 200),
      );

      expect(notificacoes.single.tipoNotificacao, isNull);
      expect(notificacoes.single.tipoEvento, isNull);
      expect(notificacoes.single.ehInterpretavel, isFalse);
    });
  });

  group('erros', () {
    test('404 com corpo JSON vira lista vazia', () async {
      final notificacoes = await comRespostaFixa(
        () => ServicesNotificacao().buscarDaPropriedade(5),
        respostaJson({'error': 'Nada encontrado'}, 404),
      );

      expect(notificacoes, isEmpty);
    });

    test('mensagem do backend sobrevive ao rethrow', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesNotificacao().marcarComoLidas([1]),
          respostaJson({'error': 'Notificação não pertence ao proprietário'}, 403),
        ),
      );

      expect(
        erro.mensagem,
        contains('Notificação não pertence ao proprietário'),
      );
    });

    test('falha de rede vira mensagem de comunicacao', () async {
      final erro = await erroDe(
        () => comFalhaDeRede(() => ServicesNotificacao().buscarDaPropriedade(5)),
      );

      expect(erro.mensagem, contains('buscar as notificações'));
    });
  });
}
