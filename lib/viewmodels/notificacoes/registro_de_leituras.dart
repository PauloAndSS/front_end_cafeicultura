import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroDeLeituras {
  static const String prefixoDaChave = 'notificacoes_lidas_';

  static String chaveDe(int idPropriedade) => '$prefixoDaChave$idPropriedade';

  final Set<int> _lidas = {};

  int? _idPropriedade;

  Set<int> get pendentes => Set.unmodifiable(_lidas);

  bool get temPendentes => _lidas.isNotEmpty;

  Future<void> sincronizarCom(
    int idPropriedade,
    List<Notificacao> doServidor,
  ) async {
    if (_idPropriedade != idPropriedade) {
      _idPropriedade = idPropriedade;

      _lidas
        ..clear()
        ..addAll(await _lerDoDisco(idPropriedade));
    }

    await _podar(doServidor);
  }

  List<Notificacao> aplicar(List<Notificacao> notificacoes) {
    if (_lidas.isEmpty) return notificacoes;

    return notificacoes
        .map(
          (notificacao) =>
              _lidas.contains(notificacao.id) ? notificacao.comoLida() : notificacao,
        )
        .toList();
  }

  Future<void> marcar(Iterable<int> ids) async {
    final anterior = _lidas.length;

    _lidas.addAll(ids);

    if (_lidas.length == anterior) return;

    await _gravar();
  }

  Future<void> confirmar(Iterable<int> ids) async {
    final anterior = _lidas.length;

    _lidas.removeAll(ids);

    if (_lidas.length == anterior) return;

    await _gravar();
  }

  Future<void> _podar(List<Notificacao> doServidor) async {
    final aindaPendentes = doServidor
        .where((notificacao) => !notificacao.lida)
        .map((notificacao) => notificacao.id)
        .toSet();

    final sobreviventes = _lidas.intersection(aindaPendentes);

    if (sobreviventes.length == _lidas.length) return;

    _lidas
      ..clear()
      ..addAll(sobreviventes);

    await _gravar();
  }

  Future<Set<int>> _lerDoDisco(int idPropriedade) async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList(chaveDe(idPropriedade)) ?? const <String>[];

    return salvos.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> _gravar() async {
    final idPropriedade = _idPropriedade;

    if (idPropriedade == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      chaveDe(idPropriedade),
      _lidas.map((id) => '$id').toList(),
    );
  }
}
