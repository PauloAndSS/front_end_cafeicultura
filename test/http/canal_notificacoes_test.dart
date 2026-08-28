import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/websocket/canal_notificacoes.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';

const Map<String, dynamic> quadroDoBackend = {
  'id': 243,
  'idProprietario': 35,
  'idPropriedade': 5,
  'idEvento': 69,
  'tipoEvento': 'tratosculturais',
  'tipoNotificacao': 'PASSADO',
  'dataCriacao': '2026-08-27T10:29:00.000Z',
  'lida': false,
};

void main() {
  group('uriDoSocket', () {
    test('deriva o endereco do emulador a partir da baseUrl', () {
      final uri = uriDoSocket('http://10.0.2.2:3333/api/v1');

      expect(uri.toString(), 'ws://10.0.2.2:3333/');
    });

    test('deriva o endereco local a partir da baseUrl', () {
      final uri = uriDoSocket('http://localhost:3333/api/v1');

      expect(uri.toString(), 'ws://localhost:3333/');
    });

    test('descarta o prefixo da API porque o upgrade nao filtra path', () {
      final uri = uriDoSocket('http://10.0.2.2:3333/api/v1');

      expect(uri.path, '/');
      expect(uri.scheme, 'ws');
      expect(uri.port, 3333);
    });
  });

  group('interpretarMensagem', () {
    test('o quadro do socket usa o mesmo fromJson do REST', () {
      final notificacao = interpretarMensagem(jsonEncode(quadroDoBackend));

      expect(notificacao, isNotNull);
      expect(notificacao!.id, 243);
      expect(notificacao.idPropriedade, 5);
      expect(notificacao.idEvento, 69);
      expect(notificacao.tipoNotificacao, TipoNotificacao.passado);
      expect(notificacao.tipoEvento, TipoEventoNotificado.tratosCulturais);
      expect(notificacao.lida, isFalse);
    });

    test('quadro malformado vira nulo em vez de derrubar a stream', () {
      expect(interpretarMensagem('{isso nao e json'), isNull);
    });

    test('quadro que nao e objeto vira nulo', () {
      expect(interpretarMensagem('[1, 2, 3]'), isNull);
      expect(interpretarMensagem('"apenas um texto"'), isNull);
    });

    test('quadro binario vira nulo', () {
      expect(interpretarMensagem([1, 2, 3]), isNull);
      expect(interpretarMensagem(null), isNull);
    });

    test('tipo desconhecido chega, mas marcado como nao interpretavel', () {
      final notificacao = interpretarMensagem(
        jsonEncode({...quadroDoBackend, 'tipoNotificacao': 'FUTURO_QUINZE'}),
      );

      expect(notificacao, isNotNull);
      expect(notificacao!.ehInterpretavel, isFalse);
    });
  });
}
