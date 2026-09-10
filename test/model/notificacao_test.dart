import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao_agrupada.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:intl/date_symbol_data_local.dart';

Notificacao notificacao({
  required int id,
  int idEvento = 43,
  String tipoNotificacao = 'PASSADO',
  String dataCriacao = '2026-08-27T07:00:00',
  bool lida = false,
}) {
  return Notificacao.fromJson({
    'id': id,
    'idProprietario': 35,
    'idPropriedade': 5,
    'idEvento': idEvento,
    'tipoEvento': 'tratosculturais',
    'tipoNotificacao': tipoNotificacao,
    'dataCriacao': dataCriacao,
    'lida': lida,
  });
}

DateTime emDias(int dias) {
  final base = hoje();

  return DateTime(base.year, base.month, base.day + dias);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('TipoNotificacao', () {
    test('deCodigo mapeia os seis codigos do backend', () {
      expect(TipoNotificacao.deCodigo('FUTURO_SETE')?.diasAteEvento, 7);
      expect(TipoNotificacao.deCodigo('FUTURO_TRES')?.diasAteEvento, 3);
      expect(TipoNotificacao.deCodigo('FUTURO_DOIS')?.diasAteEvento, 2);
      expect(TipoNotificacao.deCodigo('FUTURO_UM')?.diasAteEvento, 1);
      expect(TipoNotificacao.deCodigo('PRESENTE')?.diasAteEvento, 0);
      expect(TipoNotificacao.deCodigo('PASSADO')?.diasAteEvento, -1);
    });

    test('PRESENTE e lembrete do proprio dia, nao confirmacao', () {
      final presente = TipoNotificacao.deCodigo('PRESENTE')!;

      expect(presente.ehConfirmacao, isFalse);
      expect(presente.rotulo, 'Hoje');
    });

    test('codigo desconhecido devolve nulo em vez de estourar', () {
      expect(TipoNotificacao.deCodigo('FUTURO_QUINZE'), isNull);
      expect(TipoNotificacao.deCodigo(null), isNull);
      expect(TipoEventoNotificado.deCodigo('podas'), isNull);
    });

    test('so PASSADO pede confirmacao', () {
      final confirmacoes =
          TipoNotificacao.values.where((tipo) => tipo.ehConfirmacao);

      expect(confirmacoes, [TipoNotificacao.passado]);
    });
  });

  group('dataPrevistaDoEvento', () {
    test('desloca o dia de criacao pelo offset do tipo', () {
      final lembrete = notificacao(
        id: 1,
        tipoNotificacao: 'FUTURO_SETE',
        dataCriacao: '2026-08-27T07:00:00',
      );

      expect(lembrete.dataPrevistaDoEvento, DateTime(2026, 9, 3));
    });

    test('PRESENTE aponta para o proprio dia da criacao', () {
      final lembrete = notificacao(
        id: 4,
        tipoNotificacao: 'PRESENTE',
        dataCriacao: '2026-08-27T05:00:00',
      );

      expect(lembrete.dataPrevistaDoEvento, DateTime(2026, 8, 27));
    });

    test('PASSADO aponta para o dia anterior ao da criacao', () {
      final confirmacao = notificacao(
        id: 2,
        dataCriacao: '2026-08-27T07:00:00',
      );

      expect(confirmacao.dataPrevistaDoEvento, DateTime(2026, 8, 26));
    });

    test('atravessa a virada de mes sem somar 24 horas', () {
      final lembrete = notificacao(
        id: 3,
        tipoNotificacao: 'FUTURO_TRES',
        dataCriacao: '2026-08-30T07:00:00',
      );

      expect(lembrete.dataPrevistaDoEvento, DateTime(2026, 9, 2));
    });
  });

  group('agrupar', () {
    test('colapsa as copias do mesmo evento e tipo num grupo so', () {
      final duplicadas = [
        for (var i = 0; i < 48; i++)
          notificacao(id: 200 + i, dataCriacao: '2026-08-26T10:${i.toString().padLeft(2, '0')}:00'),
      ];

      final grupos = NotificacaoAgrupada.agrupar(duplicadas);

      expect(grupos, hasLength(1));
      expect(grupos.single.repeticoes, 48);
      expect(grupos.single.ids, hasLength(48));
    });

    test('mantem o mais recente como representante', () {
      final grupos = NotificacaoAgrupada.agrupar([
        notificacao(id: 1, dataCriacao: '2026-08-26T10:55:00'),
        notificacao(id: 2, dataCriacao: '2026-08-26T10:59:00'),
        notificacao(id: 3, dataCriacao: '2026-08-26T10:57:00'),
      ]);

      expect(grupos.single.representante.id, 2);
    });

    test('agrupa por evento, e a linha mais nova representa o grupo', () {
      final grupos = NotificacaoAgrupada.agrupar([
        notificacao(id: 1, idEvento: 43, dataCriacao: '2026-08-27T07:00:00'),
        notificacao(id: 2, idEvento: 64),
        notificacao(
          id: 3,
          idEvento: 43,
          tipoNotificacao: 'FUTURO_UM',
          dataCriacao: '2026-08-28T07:00:00',
        ),
      ]);

      expect(grupos, hasLength(2));

      final doEvento43 = grupos.singleWhere((grupo) => grupo.idEvento == 43);

      expect(doEvento43.representante.id, 3);
      expect(doEvento43.tipoNotificacao, TipoNotificacao.futuroUm);
      expect(doEvento43.ids, [1, 3]);
    });

    test('grupo com uma unica nao lida conta como nao lido', () {
      final grupos = NotificacaoAgrupada.agrupar([
        notificacao(id: 1, lida: true),
        notificacao(id: 2, lida: true),
        notificacao(id: 3, lida: false),
      ]);

      expect(grupos.single.lida, isFalse);
    });

    test('grupo inteiro lido conta como lido', () {
      final grupos = NotificacaoAgrupada.agrupar([
        notificacao(id: 1, lida: true),
        notificacao(id: 2, lida: true),
      ]);

      expect(grupos.single.lida, isTrue);
    });

    test('descarta notificacao de tipo desconhecido', () {
      final desconhecida = Notificacao.fromJson({
        'id': 9,
        'idProprietario': 35,
        'idPropriedade': 5,
        'idEvento': 43,
        'tipoEvento': 'tratosculturais',
        'tipoNotificacao': 'FUTURO_QUINZE',
        'dataCriacao': '2026-08-27T07:00:00',
        'lida': false,
      });

      final grupos = NotificacaoAgrupada.agrupar([
        desconhecida,
        notificacao(id: 10),
      ]);

      expect(grupos, hasLength(1));
      expect(grupos.single.representante.id, 10);
    });

    test('comoLida nao perde os ids do grupo', () {
      final grupo = NotificacaoAgrupada.agrupar([
        notificacao(id: 1),
        notificacao(id: 2),
      ]).single;

      final lido = grupo.comoLida();

      expect(lido.lida, isTrue);
      expect(lido.ids, grupo.ids);
      expect(lido.representante.id, grupo.representante.id);
    });
  });

  group('substituirDoEvento', () {
    test('a nova do evento derruba as antigas do mesmo evento', () {
      final atuais = [
        notificacao(id: 1, idEvento: 43, tipoNotificacao: 'FUTURO_UM'),
        notificacao(id: 2, idEvento: 64, tipoNotificacao: 'FUTURO_TRES'),
      ];
      final nova = notificacao(id: 3, idEvento: 43, tipoNotificacao: 'PASSADO');

      final resultado = Notificacao.substituirDoEvento(atuais, nova);

      expect(resultado.map((n) => n.id), [3, 2]);
    });

    test('a nova entra na frente e preserva os outros eventos', () {
      final atuais = [notificacao(id: 1, idEvento: 64)];
      final nova = notificacao(id: 2, idEvento: 43, tipoNotificacao: 'PRESENTE');

      final resultado = Notificacao.substituirDoEvento(atuais, nova);

      expect(resultado.map((n) => n.id), [2, 1]);
      expect(atuais, hasLength(1));
    });

    test('agrupar depois da substituicao mostra um grupo so por evento', () {
      final atuais = [
        notificacao(id: 1, idEvento: 43, tipoNotificacao: 'PRESENTE'),
      ];
      final nova = notificacao(id: 2, idEvento: 43, tipoNotificacao: 'PASSADO');

      final grupos = NotificacaoAgrupada.agrupar(
        Notificacao.substituirDoEvento(atuais, nova),
      );

      expect(grupos, hasLength(1));
      expect(grupos.single.tipoNotificacao, TipoNotificacao.passado);
    });
  });

  group('rotuloDeHorizonte', () {
    test('nomeia hoje, amanha e ontem em vez de contar dias', () {
      expect(rotuloDeHorizonte(emDias(0)), 'Hoje');
      expect(rotuloDeHorizonte(emDias(1)), 'Amanhã');
      expect(rotuloDeHorizonte(emDias(-1)), 'Começou ontem');
    });

    test('conta os quatro horizontes futuros do cron', () {
      expect(rotuloDeHorizonte(emDias(2)), 'Em 2 dias');
      expect(rotuloDeHorizonte(emDias(3)), 'Em 3 dias');
      expect(rotuloDeHorizonte(emDias(7)), 'Em 7 dias');
    });

    test('conta o passado alem de ontem', () {
      expect(rotuloDeHorizonte(emDias(-4)), 'Começou há 4 dias');
    });

    test('ignora a hora do dia', () {
      final base = hoje();
      final comHora = DateTime(base.year, base.month, base.day + 7, 23, 59);

      expect(rotuloDeHorizonte(comHora), 'Em 7 dias');
    });
  });

  group('textoDeQuando', () {
    test('junta o horizonte com o dia da semana por extenso', () {
      final daquiSete = emDias(7);

      expect(
        textoDeQuando(daquiSete),
        'Em 7 dias · ${formatarDataComDiaDaSemana(daquiSete)}',
      );
    });

    test('o dia da semana sai capitalizado e em pt_BR', () {
      expect(
        formatarDataComDiaDaSemana(DateTime(2026, 9, 4)),
        'Sexta-feira, 04/09/2026',
      );
      expect(
        formatarDataComDiaDaSemana(DateTime(2026, 8, 27)),
        'Quinta-feira, 27/08/2026',
      );
    });
  });

  group('Notificacao.comoLida', () {
    test('vira lida preservando o resto', () {
      final original = notificacao(id: 7, idEvento: 64);
      final lida = original.comoLida();

      expect(lida.lida, isTrue);
      expect(original.lida, isFalse);
      expect(lida.id, 7);
      expect(lida.idEvento, 64);
      expect(lida.tipoNotificacao, original.tipoNotificacao);
      expect(lida.dataCriacao, original.dataCriacao);
      expect(lida.chaveDeAgrupamento, original.chaveDeAgrupamento);
    });
  });
}
