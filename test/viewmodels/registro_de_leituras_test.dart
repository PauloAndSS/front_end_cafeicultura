import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/registro_de_leituras.dart';
import 'package:shared_preferences/shared_preferences.dart';

Notificacao notificacao({
  required int id,
  int idPropriedade = 5,
  bool lida = false,
}) {
  return Notificacao.fromJson({
    'id': id,
    'idProprietario': 35,
    'idPropriedade': idPropriedade,
    'idEvento': 70 + id,
    'tipoEvento': 'tratosculturais',
    'tipoNotificacao': 'FUTURO_UM',
    'dataCriacao': '2026-08-27T07:00:00',
    'lida': lida,
  });
}

List<Notificacao> doServidor(List<int> ids, {Set<int> lidas = const {}}) {
  return [
    for (final id in ids) notificacao(id: id, lida: lidas.contains(id)),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('persistencia', () {
    test('o que foi marcado sobrevive a uma instancia nova', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2, 3]));
      await registro.marcar([1, 3]);

      final outroBoot = RegistroDeLeituras();
      await outroBoot.sincronizarCom(5, doServidor([1, 2, 3]));

      expect(outroBoot.pendentes, {1, 3});
      expect(outroBoot.temPendentes, isTrue);
    });

    test('sem nada marcado nao ha pendencia', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2]));

      expect(registro.temPendentes, isFalse);
      expect(registro.pendentes, isEmpty);
    });

    test('propriedades diferentes nao enxergam o registro uma da outra',
        () async {
      final daPropriedadeCinco = RegistroDeLeituras();
      await daPropriedadeCinco.sincronizarCom(5, doServidor([1, 2]));
      await daPropriedadeCinco.marcar([1]);

      final daPropriedadeSete = RegistroDeLeituras();
      await daPropriedadeSete.sincronizarCom(7, doServidor([1, 2]));

      expect(daPropriedadeSete.pendentes, isEmpty);
    });

    test('trocar de propriedade e voltar recupera o registro certo', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2]));
      await registro.marcar([2]);

      await registro.sincronizarCom(7, doServidor([1, 2]));
      expect(registro.pendentes, isEmpty);

      await registro.sincronizarCom(5, doServidor([1, 2]));
      expect(registro.pendentes, {2});
    });
  });

  group('aplicar', () {
    test('vira lida so os ids marcados', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2, 3]));
      await registro.marcar([2]);

      final aplicadas = registro.aplicar(doServidor([1, 2, 3]));

      expect(aplicadas.map((n) => n.lida), [false, true, false]);
    });

    test('sem nada marcado devolve a lista intacta', () async {
      final registro = RegistroDeLeituras();
      final original = doServidor([1, 2]);

      await registro.sincronizarCom(5, original);

      expect(registro.aplicar(original), same(original));
    });
  });

  group('poda', () {
    test('descarta id que o servidor ja devolve como lido', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2]));
      await registro.marcar([1, 2]);

      await registro.sincronizarCom(5, doServidor([1, 2], lidas: {1}));

      expect(registro.pendentes, {2});
    });

    test('descarta id que sumiu da lista da propriedade', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2]));
      await registro.marcar([1, 2]);

      await registro.sincronizarCom(5, doServidor([2]));

      expect(registro.pendentes, {2});
    });

    test('a poda tambem grava, nao so limpa a memoria', () async {
      final registro = RegistroDeLeituras();

      await registro.sincronizarCom(5, doServidor([1, 2]));
      await registro.marcar([1, 2]);
      await registro.sincronizarCom(5, doServidor([1, 2], lidas: {1}));

      final outroBoot = RegistroDeLeituras();
      await outroBoot.sincronizarCom(5, doServidor([1, 2], lidas: {1}));

      expect(outroBoot.pendentes, {2});
    });
  });
}
