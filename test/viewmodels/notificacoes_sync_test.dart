import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/notificacoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/registro_de_leituras.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/mock_http.dart';

const int idPropriedade = 5;

Map<String, dynamic> notificacaoJson({
  required int id,
  required int idEvento,
  String tipoNotificacao = 'FUTURO_UM',
  bool lida = false,
}) {
  return {
    'id': id,
    'idProprietario': 35,
    'idPropriedade': idPropriedade,
    'idEvento': idEvento,
    'tipoEvento': 'tratosculturais',
    'tipoNotificacao': tipoNotificacao,
    'dataCriacao': '2026-08-27T07:00:00',
    'lida': lida,
  };
}

class Servidor {
  Servidor({required this.notificacoes, this.statusDaLeitura = 404});

  final List<Map<String, dynamic>> notificacoes;
  final int statusDaLeitura;

  final List<http.Request> leituras = [];

  MockClient get cliente => MockClient((requisicao) async {
        final caminho = requisicao.url.path;

        if (requisicao.method == 'PATCH' && caminho.endsWith('/lida')) {
          leituras.add(requisicao);

          return respostaSemCorpo(statusDaLeitura);
        }

        if (caminho.contains('notificacoes/propriedades/')) {
          return respostaJson(notificacoes, 200);
        }

        return respostaJson(const [], 200);
      });

  List<int> get idsEnviados {
    final corpo = jsonDecode(leituras.single.body) as Map<String, dynamic>;

    return (corpo['idsNotificacoes'] as List).cast<int>();
  }

  Future<T> atende<T>(Future<T> Function() acao) =>
      http.runWithClient(acao, () => cliente);

  Future<void> umaVisitaCompleta() {
    return atende(() async {
      final viewModel = NotificacoesViewModel();

      await viewModel.carregar(idPropriedade);
      await viewModel.encerrarVisita();

      viewModel.dispose();
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('encerrarVisita nao gasta requisicao a toa', () {
    test('sem nada pendente, nenhuma requisicao de leitura sai', () async {
      final servidor = Servidor(
        notificacoes: [
          notificacaoJson(id: 1, idEvento: 71, lida: true),
          notificacaoJson(id: 2, idEvento: 72, lida: true),
        ],
      );

      await servidor.umaVisitaCompleta();

      expect(servidor.leituras, isEmpty);
    });

    test('lista vazia tambem nao dispara leitura', () async {
      final servidor = Servidor(notificacoes: const []);

      await servidor.umaVisitaCompleta();

      expect(servidor.leituras, isEmpty);
    });

    test('so a confirmacao pendente nao gera requisicao nenhuma', () async {
      final servidor = Servidor(
        notificacoes: [
          notificacaoJson(id: 9, idEvento: 79, tipoNotificacao: 'PASSADO'),
        ],
      );

      await servidor.umaVisitaCompleta();

      expect(servidor.leituras, isEmpty);
    });
  });

  group('encerrarVisita agrupa numa requisicao so', () {
    test('a auto-leitura dos lembretes vira um unico PATCH', () async {
      final servidor = Servidor(
        notificacoes: [
          notificacaoJson(id: 1, idEvento: 71),
          notificacaoJson(id: 2, idEvento: 72, tipoNotificacao: 'FUTURO_TRES'),
          notificacaoJson(id: 3, idEvento: 73, tipoNotificacao: 'FUTURO_SETE'),
        ],
      );

      await servidor.umaVisitaCompleta();

      expect(servidor.leituras, hasLength(1));
      expect(servidor.idsEnviados..sort(), [1, 2, 3]);
    });

    test('a confirmacao pendente fica de fora do lote', () async {
      final servidor = Servidor(
        notificacoes: [
          notificacaoJson(id: 1, idEvento: 71),
          notificacaoJson(id: 9, idEvento: 79, tipoNotificacao: 'PASSADO'),
        ],
      );

      await servidor.umaVisitaCompleta();

      expect(servidor.idsEnviados, [1]);
    });

    test('o deslizar nao vai a rede; so o fechamento vai', () async {
      final servidor = Servidor(
        notificacoes: [notificacaoJson(id: 1, idEvento: 71)],
      );

      await servidor.atende(() async {
        final viewModel = NotificacoesViewModel();
        await viewModel.carregar(idPropriedade);

        final marcou = await viewModel.marcarComoLida(viewModel.naoLidas.single);

        expect(marcou, isTrue);
        expect(servidor.leituras, isEmpty);
        expect(viewModel.naoLidas, isEmpty);
        expect(viewModel.lidas, hasLength(1));

        await viewModel.encerrarVisita();
        viewModel.dispose();
      });

      expect(servidor.leituras, hasLength(1));
    });
  });

  group('o registro local sobrevive ao desfecho da requisicao', () {
    Future<Set<int>> pendentesNoDisco(List<Map<String, dynamic>> doServidor) {
      final registro = RegistroDeLeituras();
      final notificacoes = doServidor.map(Notificacao.fromJson).toList();

      return registro
          .sincronizarCom(idPropriedade, notificacoes)
          .then((_) => registro.pendentes);
    }

    test('flush que falha nao apaga os ids', () async {
      final lista = [
        notificacaoJson(id: 1, idEvento: 71),
        notificacaoJson(id: 2, idEvento: 72),
      ];

      final servidor = Servidor(notificacoes: lista, statusDaLeitura: 404);
      await servidor.umaVisitaCompleta();

      expect(await pendentesNoDisco(lista), {1, 2});
    });

    test('flush aceito tambem nao apaga: quem confirma e a carga seguinte',
        () async {
      final lista = [notificacaoJson(id: 1, idEvento: 71)];

      final servidor = Servidor(notificacoes: lista, statusDaLeitura: 204);
      await servidor.umaVisitaCompleta();

      expect(servidor.leituras, hasLength(1));
      expect(await pendentesNoDisco(lista), {1});
    });

    test('o servidor devolvendo lida e o que poda o registro', () async {
      final lista = [notificacaoJson(id: 1, idEvento: 71)];

      final servidor = Servidor(notificacoes: lista, statusDaLeitura: 204);
      await servidor.umaVisitaCompleta();

      final jaLida = [notificacaoJson(id: 1, idEvento: 71, lida: true)];

      expect(await pendentesNoDisco(jaLida), isEmpty);
    });
  });
}
