import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

abstract class AgendaMensalViewModel<T extends EventoAgricola>
    extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin, CarregarTalhoesMixin {
  final Map<String, List<T>> _cachePorMes = {};

  int? _idPropriedade;
  DateTime? _mesVisivel;

  bool _carregouAlgumaVez = false;
  bool get carregouAlgumaVez => _carregouAlgumaVez;

  DateTime? get mesVisivel => _mesVisivel;

  List<T> get atividadesDoMes {
    if (_idPropriedade == null || _mesVisivel == null) return const [];

    return _cachePorMes[_chave(_idPropriedade!, _mesVisivel!)] ?? const [];
  }

  @protected
  Future<List<T>> buscarNoPeriodo(
    int idPropriedade,
    DateTime inicio,
    DateTime fim,
  );

  Future<void> carregarMes(
    int idPropriedade,
    DateTime data, {
    bool forcar = false,
  }) async {
    final mes = _primeiroDiaDoMes(data);
    final chave = _chave(idPropriedade, mes);

    final mudouDeMes = _idPropriedade != idPropriedade || _mesVisivel != mes;

    _idPropriedade = idPropriedade;
    _mesVisivel = mes;

    if (!forcar && _cachePorMes.containsKey(chave)) {
      if (mudouDeMes) notificarSeVivo();
      return;
    }

    if (isLoading) return;

    await cargaPrincipal.executar(
      chamada: () async {
        _cachePorMes[chave] = await _buscarMesInteiro(idPropriedade, mes);
      },
      aoFalhar: () {},
      aoFinalizar: () => _carregouAlgumaVez = true,
    );
  }

  Future<void> recarregarMesVisivel() {
    if (_idPropriedade == null || _mesVisivel == null) return Future.value();

    return carregarMes(_idPropriedade!, _mesVisivel!, forcar: true);
  }

  int _geracaoDoCacheVista = 0;

  void sincronizarCom(int geracaoDoCache) {
    if (geracaoDoCache == _geracaoDoCacheVista) return;

    _geracaoDoCacheVista = geracaoDoCache;
    recarregarMesVisivel();
  }

  void limparCache() {
    _cachePorMes.clear();
    mensagemErro = null;
    _carregouAlgumaVez = false;
    notificarSeVivo();
  }

  Future<List<T>> _buscarMesInteiro(int idPropriedade, DateTime mes) async {
    final buscaTalhoes = carregarTalhoes(idPropriedade);

    try {
      return await buscarNoPeriodo(
        idPropriedade,
        _primeiroInstanteDoMes(mes),
        _ultimoInstanteDoMes(mes),
      );
    } finally {
      await buscaTalhoes;
    }
  }

  String _chave(int idPropriedade, DateTime mes) =>
      '$idPropriedade|${formatarAnoMes(mes)}';

  DateTime _primeiroDiaDoMes(DateTime data) => DateTime(data.year, data.month);

  DateTime _primeiroInstanteDoMes(DateTime mes) =>
      DateTime.utc(mes.year, mes.month);

  DateTime _ultimoInstanteDoMes(DateTime mes) =>
      DateTime.utc(mes.year, mes.month + 1, 0, 23, 59, 59, 999);
}
