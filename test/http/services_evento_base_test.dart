import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:http/http.dart' as http;

import 'mock_http.dart';

Map<String, dynamic> tratoJson({int id = 69, String? dataFim}) {
  return {
    'id': id,
    'dataInicio': '2026-08-26T12:00:00.000Z',
    'dataFim': dataFim,
    'descricao': '',
    'dataCadastro': '2026-08-26T10:50:50.000Z',
    'safra': {'id': 5, 'idPropriedade': 5},
    'transacoesFinanceiras': [],
    'responsaveis': [],
    'idTalhao': 54,
    'tipoTrato': 'Adubação',
  };
}

TratoCultural tratoParaEnviar() => TratoCultural(
      idTalhao: 54,
      idSafra: 5,
      tipoTrato: TipoTrato('Adubação'),
      dataInicio: DateTime(2026, 8, 26),
    );

void main() {
  setUp(() => BaseService.sessionCookie = null);

  group('buscarPorId', () {
    test('usa GET na rota do recurso com o id', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesTratoCultural().buscarPorId(69),
        respostaJson(tratoJson(), 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'GET');
      expect(enviada.url.path, endsWith('/tratosculturais/69'));
    });

    test('devolve o trato desserializado com o tipo e o talhao', () async {
      final trato = await comRespostaFixa(
        () => ServicesTratoCultural().buscarPorId(69),
        respostaJson(tratoJson(), 200),
      );

      expect(trato.id, 69);
      expect(trato.idTalhao, 54);
      expect(trato.idSafra, 5);
      expect(trato.tipoTrato.descricao, 'Adubação');
      expect(trato.finalizado, isFalse);
    });

    test('trato com dataFim é reconhecido como finalizado', () async {
      final trato = await comRespostaFixa(
        () => ServicesTratoCultural().buscarPorId(69),
        respostaJson(tratoJson(dataFim: '2026-08-26T12:00:00.000Z'), 200),
      );

      expect(trato.finalizado, isTrue);
    });

    test('mensagem do backend sobrevive ao rethrow', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesTratoCultural().buscarPorId(69),
          respostaJson({'error': 'Acesso negado!'}, 403),
        ),
      );

      expect(erro.mensagem, contains('Acesso negado!'));
    });
  });

  group('editar', () {
    test('usa PUT na rota do recurso com o corpo completo', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServicesTratoCultural().editar(69, tratoParaEnviar()),
        respostaJson(tratoJson(id: 70), 201),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'PUT');
      expect(enviada.url.path, endsWith('/tratosculturais/69'));

      final corpo = jsonDecode(enviada.body) as Map<String, dynamic>;

      expect(corpo['idTalhao'], 54);
      expect(corpo['idSafra'], 5);
      expect(corpo['tipoTrato'], 'Adubação');
      expect(corpo['dataInicio'], '2026-08-26T12:00:00.000Z');
      expect(corpo['responsaveisIds'], isEmpty);
    });

    test('aceita 201 como sucesso e devolve o trato com o id novo', () async {
      final atualizado = await comRespostaFixa(
        () => ServicesTratoCultural().editar(69, tratoParaEnviar()),
        respostaJson(tratoJson(id: 70), 201),
      );

      expect(atualizado.id, 70);
    });

    test('erro de validacao do backend chega a tela', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServicesTratoCultural().editar(69, tratoParaEnviar()),
          respostaJson({'error': 'DATA_INICIO_ANTERIOR'}, 400),
        ),
      );

      expect(erro.mensagem, contains('DATA_INICIO_ANTERIOR'));
    });
  });
}
