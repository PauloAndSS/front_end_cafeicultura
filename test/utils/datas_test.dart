import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';

DateTime _meioDiaUtcDe(DateTime dia) =>
    DateTime.utc(dia.year, dia.month, dia.day, 12);

void main() {
  group('diaNaoFuturoParaJson', () {
    test('dia passado viaja em meio-dia UTC, como sempre', () {
      final ontem = apenasData(DateTime.now()).subtract(const Duration(days: 1));

      expect(
        diaNaoFuturoParaJson(ontem),
        _meioDiaUtcDe(ontem).toIso8601String(),
      );
    });

    test('dia futuro viaja em meio-dia UTC e nunca e clampado', () {
      final proximaSemana =
          apenasData(DateTime.now()).add(const Duration(days: 7));

      expect(
        diaNaoFuturoParaJson(proximaSemana),
        _meioDiaUtcDe(proximaSemana).toIso8601String(),
      );
    });

    test('o dia de hoje nunca sai a frente do instante da chamada', () {
      final agora = DateTime.now();
      final enviado = DateTime.parse(diaNaoFuturoParaJson(hoje(), agora: agora));

      expect(enviado.isAfter(agora.toUtc()), isFalse);
    });

    test('o valor enviado volta como o mesmo dia local', () {
      for (final agora in [
        apenasData(DateTime.now()),
        DateTime.now(),
        apenasData(DateTime.now()).add(const Duration(hours: 23, minutes: 59)),
      ]) {
        final dia = apenasData(agora);
        final enviado = diaNaoFuturoParaJson(dia, agora: agora);

        expect(apenasData(lerDataDoJson(enviado)!.toLocal()), dia);
      }
    });


    test('as 24 horas do dia mandam data aceitavel e do dia certo', () {
      for (var hora = 0; hora < 24; hora++) {
        for (final minuto in [0, 30, 59]) {
          final agora = DateTime(2026, 8, 27, hora, minuto);
          final dia = apenasData(agora);
          final enviado =
              DateTime.parse(diaNaoFuturoParaJson(dia, agora: agora));

          expect(enviado.isAfter(agora.toUtc()), isFalse,
              reason: 'as ${hora}h$minuto o backend recusaria como futura');
          expect(apenasData(enviado.toLocal()), dia,
              reason: 'as ${hora}h$minuto o dia voltaria trocado');
        }
      }
    });

    test('o dia certo vence a margem nos primeiros minutos do dia', () {
      for (final minuto in [0, 1, 4]) {
        final agora = DateTime(2026, 8, 27, 0, minuto);
        final dia = apenasData(agora);
        final enviado = DateTime.parse(diaNaoFuturoParaJson(dia, agora: agora));

        expect(enviado, dia.toUtc(),
            reason: 'recuar a margem cruzaria para o dia anterior');
        expect(apenasData(enviado.toLocal()), dia);
      }
    });

    test('fora dos primeiros minutos, sobra a folga de relogio inteira', () {

      for (final hora in [1, 3, 6, 8]) {
        final agora = DateTime(2026, 8, 27, hora, 30);
        final dia = apenasData(agora);
        final enviado = DateTime.parse(diaNaoFuturoParaJson(dia, agora: agora));

        expect(agora.toUtc().difference(enviado) >= margemDeRelogio, isTrue,
            reason: 'as ${hora}h30 um servidor atrasado recusaria de novo');
        expect(apenasData(enviado.toLocal()), dia);
      }
    });

    test('a virada para o marcador tambem respeita a folga', () {
      final logoAposOMeioDiaUtc =
          DateTime.utc(2026, 8, 27, 12, 1).toLocal();
      final dia = apenasData(logoAposOMeioDiaUtc);
      final enviado = DateTime.parse(
          diaNaoFuturoParaJson(dia, agora: logoAposOMeioDiaUtc));

      expect(
        logoAposOMeioDiaUtc.toUtc().difference(enviado) >= margemDeRelogio,
        isTrue,
        reason: 'o marcador sairia 1 min a frente de um servidor atrasado',
      );
      expect(apenasData(enviado.toLocal()), dia);
    });

    test('virada de meia-noite mantem o dia que a tela escolheu', () {
      final ontem = DateTime(2026, 8, 26);
      final logoAposAVirada = DateTime(2026, 8, 27, 0, 0, 1);

      final enviado =
          DateTime.parse(diaNaoFuturoParaJson(ontem, agora: logoAposAVirada));

      expect(enviado, _meioDiaUtcDe(ontem));
      expect(apenasData(enviado.toLocal()), ontem);
    });

    // Os dois casos abaixo fixam o valor exato e assumem os fusos que o app
    // atende: Brasil (UTC-3) e o GMT do emulador.
    test('hoje, antes de o meio-dia UTC chegar, sai o instante recuado', () {
      final agora = DateTime.utc(2026, 8, 27, 10, 40).toLocal();
      final dia = apenasData(agora);

      expect(_meioDiaUtcDe(dia).isAfter(agora.toUtc()), isTrue,
          reason: 'fuso do ambiente de teste fora de Brasil/GMT');

      expect(
        diaNaoFuturoParaJson(dia, agora: agora),
        agora.toUtc().subtract(margemDeRelogio).toIso8601String(),
      );
    });

    test('hoje, depois do meio-dia UTC, sai o marcador de sempre', () {
      final agora = DateTime.utc(2026, 8, 27, 15, 50).toLocal();
      final dia = apenasData(agora);

      expect(_meioDiaUtcDe(dia).isAfter(agora.toUtc()), isFalse,
          reason: 'fuso do ambiente de teste fora de Brasil/GMT');

      expect(
        diaNaoFuturoParaJson(dia, agora: agora),
        _meioDiaUtcDe(dia).toIso8601String(),
      );
    });
  });
}
