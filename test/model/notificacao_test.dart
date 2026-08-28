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
    test('deCodigo mapeia os cinco codigos do backend', () {
      expect(TipoNotificacao.deCodigo('FUTURO_SETE')?.diasAteEvento, 7);
      expect(TipoNotificacao.deCodigo('FUTURO_TRES')?.diasAteEvento, 3);
      expect(TipoNotificacao.deCodigo('FUTURO_DOIS')?.diasAteEvento, 2);
      expect(TipoNotificacao.deCodigo('FUTURO_UM')?.diasAteEvento, 1);
      expect(TipoNotificacao.deCodigo('PASSADO')?.diasAteEvento, -1);
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

    test('separa por evento e por tipo de notificacao', () {
      final grupos = NotificacaoAgrupada.agrupar([
        notificacao(id: 1, idEvento: 43),
        notificacao(id: 2, idEvento: 64),
        notificacao(id: 3, idEvento: 43, tipoNotificacao: 'FUTURO_UM'),
      ]);

      expect(grupos, hasLength(3));
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
