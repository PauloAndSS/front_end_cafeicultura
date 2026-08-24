import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class SafraViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final ServicesSafra _service = ServicesSafra();

  late final EstadoDeCarga _cargaRelatorio = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  late final EstadoDeCarga _cargaReleitura = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  List<Safra> _safras = [];
  Safra? _safraSelecionada;
  List<EventoAgricola> _relatorio = [];
  int? _propriedadeIdAtual;
  bool _dadosCarregados = false;

  final Map<int, List<Safra>> _cacheSafrasPorPropriedade = {};

  final Map<int, int?> _cacheSafraSelecionadaPorPropriedade = {};

  bool get isLoadingRelatorio => _cargaRelatorio.isLoading;
  List<Safra> get safras => _safras;
  Safra? get safraSelecionada => _safraSelecionada;
  List<EventoAgricola> get relatorio => _relatorio;
  int? get propriedadeIdAtual => _propriedadeIdAtual;
  bool get dadosCarregados => _dadosCarregados;

  List<Safra> safrasAbertasEm(DateTime dia) => _safras
      .where((safra) => safra.id != null)
      .where((safra) => safra.periodo?.contem(dia) ?? false)
      .toList();

  Safra? safraPorId(int? id) {
    if (id == null) return null;

    for (final safra in _safras) {
      if (safra.id == id) return safra;
    }

    return null;
  }

  Future<void> carregarDadosDaPropriedade(
    int idPropriedade, {
    bool forcarAtualizacao = false,
  }) async {
    if (!forcarAtualizacao && _propriedadeIdAtual == idPropriedade && _dadosCarregados) {
      return;
    }

    if (!forcarAtualizacao && _cacheSafrasPorPropriedade.containsKey(idPropriedade)) {
      _propriedadeIdAtual = idPropriedade;
      mensagemErro = null;
      _restaurarSafrasDoCache(idPropriedade);
      _dadosCarregados = true;
      notificarSeVivo();

      if (_safraSelecionada?.id != null) {
        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      }
      return;
    }

    _propriedadeIdAtual = idPropriedade;

    await cargaPrincipal.executar(
      chamada: () async {
        final safrasCarregadas =
            _ordenarSafras(await _service.buscarPorPropriedade(idPropriedade));

        if (safrasCarregadas.isEmpty) {
          _safras = [];
          _safraSelecionada = null;
          _relatorio = [];
          _salvarSafrasNoCache(idPropriedade, _safras);
          return;
        }

        _safras = safrasCarregadas;
        _salvarSafrasNoCache(idPropriedade, _safras);

        _safraSelecionada = _safras.first;
        _cacheSafraSelecionadaPorPropriedade[idPropriedade] =
            _safraSelecionada!.id;

        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      },
      aoFalhar: () {},
    );

    _dadosCarregados = true;
    notificarSeVivo();
  }

  void _restaurarSafrasDoCache(int idPropriedade) {
    _safras = List<Safra>.from(_cacheSafrasPorPropriedade[idPropriedade] ?? const []);

    final idSelecionadaCache = _cacheSafraSelecionadaPorPropriedade[idPropriedade];
    Safra? safraRestaurada;
    if (idSelecionadaCache != null) {
      for (final safra in _safras) {
        if (safra.id == idSelecionadaCache) {
          safraRestaurada = safra;
          break;
        }
      }
    }
    _safraSelecionada = safraRestaurada ?? (_safras.isNotEmpty ? _safras.first : null);
  }

  void _salvarSafrasNoCache(int idPropriedade, List<Safra> safras) {
    _cacheSafrasPorPropriedade[idPropriedade] = List<Safra>.from(safras);
  }

  void limparCacheSessao({int? idPropriedade}) {
    if (idPropriedade != null) {
      _cacheSafrasPorPropriedade.remove(idPropriedade);
      _cacheSafraSelecionadaPorPropriedade.remove(idPropriedade);
      if (_propriedadeIdAtual == idPropriedade) {
        _dadosCarregados = false;
      }
    } else {
      _cacheSafrasPorPropriedade.clear();
      _cacheSafraSelecionadaPorPropriedade.clear();
      _dadosCarregados = false;
    }
    notificarSeVivo();
  }

  Future<void> selecionarSafra(Safra safra) async {
    if (_safraSelecionada?.id == safra.id) {
      return;
    }

    _safraSelecionada = safra;
    _relatorio = [];
    notificarSeVivo();

    if (_propriedadeIdAtual == null || safra.id == null) {
      return;
    }

    _cacheSafraSelecionadaPorPropriedade[_propriedadeIdAtual!] = safra.id;

    await carregarRelatorioDaSafra(
      idPropriedade: _propriedadeIdAtual!,
      idSafra: safra.id!,
    );
  }

  Future<void> carregarRelatorioDaSafra({
    required int idPropriedade,
    required int idSafra,
  }) {
    return _cargaRelatorio.executar(
      chamada: () async {
        _relatorio = await _service.buscarRelatorio(
          idPropriedade: idPropriedade,
          idSafra: idSafra,
        );
      },
      aoFalhar: () {},
    );
  }

  Future<bool> criarSafra({
    required int idPropriedade,
    DateTime? dataInicio,
  }) {
    return cargaPrincipal.executar(
      chamada: () async {
        await _service.cadastrar(
          idPropriedade: idPropriedade,
          dataInicio: dataInicio,
        );
        await _refreshSafrasAfterMutation(
          idPropriedade,
          selecionarMaisRecente: true,
        );
        return true;
      },
      aoFalhar: () => false,
    );
  }

  Future<bool> encerrarSafra({
    required int idPropriedade,
    required int idSafra,
    DateTime? dataFim,
  }) {
    if (idSafra <= 0) {
      mensagemErro = 'Selecione uma safra válida para encerrar.';
      notificarSeVivo();
      return Future.value(false);
    }

    return cargaPrincipal.executar(
      chamada: () async {
        await _service.encerrar(idSafra, dataFim: dataFim);
        await _refreshSafrasAfterMutation(idPropriedade);
        return true;
      },
      aoFalhar: () => false,
    );
  }

  Future<bool> reativarSafra({
    required int idPropriedade,
    required int idSafra,
  }) {
    if (idSafra <= 0) {
      mensagemErro = 'Selecione uma safra válida para reativar.';
      notificarSeVivo();
      return Future.value(false);
    }

    return cargaPrincipal.executar(
      chamada: () async {
        await _service.reativar(idSafra);
        await _refreshSafrasAfterMutation(idPropriedade);
        return true;
      },
      aoFalhar: () => false,
    );
  }

  Future<void> _refreshSafrasAfterMutation(
    int idPropriedade, {
    bool selecionarMaisRecente = false,
  }) {
    return _cargaReleitura.executar(
      chamada: () async {
        final novasSafras = _ordenarSafras(await _service.buscarPorPropriedade(idPropriedade));
        _safras = novasSafras;
        _salvarSafrasNoCache(idPropriedade, _safras);

        if (novasSafras.isEmpty) {
          _safraSelecionada = null;
          _relatorio = [];
          _cacheSafraSelecionadaPorPropriedade.remove(idPropriedade);
          return;
        }

        if (selecionarMaisRecente ||
            _safraSelecionada == null ||
            !novasSafras.any((safra) => safra.id == _safraSelecionada?.id)) {
          _safraSelecionada = _safras.first;
        } else {
          _safraSelecionada = novasSafras.firstWhere(
            (safra) => safra.id == _safraSelecionada!.id,
            orElse: () => _safraSelecionada!,
          );
        }

        _cacheSafraSelecionadaPorPropriedade[idPropriedade] = _safraSelecionada!.id;

        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      },
      aoFalhar: () {},
    );
  }

  List<Safra> _ordenarSafras(List<Safra> safras) {
    final copia = List<Safra>.from(safras);
    copia.sort((a, b) {
      final dataA = a.dataInicio ?? a.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB = b.dataInicio ?? b.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final comparacaoData = dataB.compareTo(dataA);
      if (comparacaoData != 0) {
        return comparacaoData;
      }
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return copia;
  }
}
