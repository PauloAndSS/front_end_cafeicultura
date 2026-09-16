import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

mixin CarregarTalhoesMixin on NotificaSeVivoMixin {
  static const int _maxPaginas = 50;

  final _talhaoService = ServicesTalhao();

  late final EstadoDeCarga _cargaTalhoes = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  final List<Talhao> _talhoes = [];
  List<Talhao> get talhoes => List.unmodifiable(_talhoes);

  List<Talhao> talhoesAbertosEm(DateTime dia) => _talhoes
      .where((talhao) => talhao.id != null)
      .where((talhao) => talhao.periodo.contem(dia))
      .toList();

  bool _talhoesCarregados = false;
  bool get talhoesCarregados => _talhoesCarregados;

  bool get isCarregandoTalhoes => _cargaTalhoes.isLoading;

  String? get mensagemErroTalhoes => _cargaTalhoes.mensagemErro;

  Talhao? talhaoPorId(int idTalhao) {
    for (final talhao in _talhoes) {
      if (talhao.id == idTalhao) return talhao;
    }
    return null;
  }

  String nomeDoTalhao(int idTalhao) =>
      talhaoPorId(idTalhao)?.nomeExibicao ?? 'Talhão #$idTalhao';

  Future<void> carregarTalhoes(int idPropriedade) {
    if (_cargaTalhoes.isLoading) return Future.value();

    return _cargaTalhoes.executar(
      chamada: () async {
        final carregados = <Talhao>[];
        var pagina = 1;

        while (pagina <= _maxPaginas) {
          final lote = await _talhaoService.buscarPorPropriedade(
            idPropriedade,
            pagina: pagina,
          );

          carregados.addAll(lote);

          if (lote.length < ServicesTalhao.limitePorPagina) break;
          pagina++;
        }

        _talhoes
          ..clear()
          ..addAll(carregados);
        _talhoesCarregados = true;
      },
      aoFalhar: () {},
    );
  }
}
