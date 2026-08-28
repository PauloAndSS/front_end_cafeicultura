import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';

int calcularDiferencaDias(DateTime dataEvento, DateTime dataAtual) {
  final utcEvento = DateTime.utc(
    dataEvento.year,
    dataEvento.month,
    dataEvento.day,
  );

  final utcAtual = DateTime.utc(
    dataAtual.year,
    dataAtual.month,
    dataAtual.day,
  );

  final diferenca = utcEvento.difference(utcAtual).inMilliseconds;

  return (diferenca / Duration.millisecondsPerDay).round();
}

int diffDoCron(String dataInicioGravada, DateTime instanteDoCron) =>
    calcularDiferencaDias(DateTime.parse(dataInicioGravada), instanteDoCron);

void main() {
  final cron = DateTime(2026, 8, 28, 7);

  group('dataParaJson ignora a hora do cadastro', () {
    test('as 24 horas do dia geram o mesmo meio-dia UTC', () {
      for (var hora = 0; hora < 24; hora++) {
        for (final minuto in [0, 30, 59]) {
          expect(
            dataParaJson(DateTime(2026, 9, 4, hora, minuto)),
            '2026-09-04T12:00:00.000Z',
            reason: 'cadastro as $hora:$minuto mudou o valor gravado',
          );
        }
      }
    });

    test('o dia gravado nunca escorrega para o vizinho', () {
      for (var hora = 0; hora < 24; hora++) {
        final gravado = DateTime.parse(dataParaJson(DateTime(2026, 9, 4, hora)));

        expect(gravado.day, 4);
        expect(gravado.month, 9);
        expect(gravado.isUtc, isTrue);
      }
    });
  });

  group('o cron classifica o evento no dia certo', () {
    test('os cinco offsets caem nos tipos esperados', () {
      final esperados = {
        DateTime(2026, 9, 4): 7,
        DateTime(2026, 8, 31): 3,
        DateTime(2026, 8, 30): 2,
        DateTime(2026, 8, 29): 1,
        DateTime(2026, 8, 27): -1,
      };

      esperados.forEach((diaDoEvento, diferencaEsperada) {
        expect(
          diffDoCron(dataParaJson(diaDoEvento), cron),
          diferencaEsperada,
          reason: 'evento em $diaDoEvento foi classificado errado',
        );
      });
    });

    test('a hora do cadastro nao muda a classificacao', () {
      for (var hora = 0; hora < 24; hora++) {
        final gravado = dataParaJson(DateTime(2026, 9, 4, hora, 45));

        expect(diffDoCron(gravado, cron), 7);
      }
    });

    test('o dia do evento nao gera notificacao', () {
      expect(diffDoCron(dataParaJson(DateTime(2026, 8, 28)), cron), 0);
    });

    test('a classificacao se mantem em qualquer hora de disparo', () {
      final gravado = dataParaJson(DateTime(2026, 8, 29));

      for (var hora = 0; hora < 24; hora++) {
        expect(
          diffDoCron(gravado, DateTime(2026, 8, 28, hora)),
          1,
          reason: 'cron disparado as $hora classificou errado',
        );
      }
    });
  });

  group('regressao: instante em vez de meio-dia construido', () {
    test('o instante de um cadastro noturno adianta o evento um dia', () {
      final gravadoCorreto = dataParaJson(DateTime(2026, 9, 4, 22));
      final gravadoComoInstante =
          DateTime.utc(2026, 9, 5, 1).toIso8601String();

      expect(diffDoCron(gravadoCorreto, cron), 7);
      expect(diffDoCron(gravadoComoInstante, cron), 8);
    });

    test('instanteParaJson nao preserva o dia escolhido', () {
      final escolhido = DateTime(2026, 9, 4, 22);

      final comoInstante = DateTime.parse(instanteParaJson(escolhido));
      final comoDia = DateTime.parse(dataParaJson(escolhido));

      expect(comoDia.day, 4);
      expect(comoInstante.hour, isNot(12));
    });
  });

  group('diaSeguinte cobre a regra do dia posterior ao inicio', () {
    test('conta calendario, nao 24 horas', () {
      expect(diaSeguinte(DateTime(2026, 8, 31)), DateTime(2026, 9, 1));
      expect(diaSeguinte(DateTime(2026, 12, 31)), DateTime(2027, 1, 1));
    });

    test('o dia da confirmacao é o seguinte ao inicio', () {
      final inicio = DateTime(2026, 8, 27);
      final diaDaConfirmacao = diaSeguinte(inicio);

      expect(diffDoCron(dataParaJson(inicio), diaDaConfirmacao), -1);
    });
  });

  group('diasEntre normaliza o dia antes de subtrair', () {
    test('conta dias de calendario, nao blocos de 24 horas', () {
      expect(diasEntre(DateTime(2026, 8, 28, 23, 59), DateTime(2026, 8, 29, 0, 1)), 1);
      expect(diasEntre(DateTime(2026, 8, 28, 0, 1), DateTime(2026, 8, 28, 23, 59)), 0);
    });

    test('atravessa mes e ano', () {
      expect(diasEntre(DateTime(2026, 8, 28), DateTime(2026, 9, 4)), 7);
      expect(diasEntre(DateTime(2026, 12, 31), DateTime(2027, 1, 1)), 1);
    });

    test('devolve negativo para o passado', () {
      expect(diasEntre(DateTime(2026, 8, 28), DateTime(2026, 8, 27)), -1);
    });

    test('bate com o calculo do cron para os cinco horizontes', () {
      final cronDia = DateTime(2026, 8, 28, 7);

      for (final offset in [7, 3, 2, 1, -1]) {
        final evento = DateTime(2026, 8, 28 + offset);

        expect(diasEntre(cronDia, evento), offset);
        expect(diffDoCron(dataParaJson(evento), cronDia), offset);
      }
    });
  });
}
