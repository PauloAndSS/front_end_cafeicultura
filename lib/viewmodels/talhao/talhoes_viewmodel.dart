import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class TalhoesViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  late final EstadoDeCarga _cargaMais = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  List<Talhao> _todosTalhoes = [];

  int _paginaAtual = 1;
  bool _temMaisPaginas = true;
  int? _idPropriedadeAtual;

  bool get isLoadingMais => _cargaMais.isLoading;
  bool get temMaisPaginas => _temMaisPaginas;
  int? get idPropriedadeAtual => _idPropriedadeAtual;
  List<Talhao> get talhoes => _todosTalhoes;

  List<Talhao> get talhoesAtivos =>
      _todosTalhoes.where((talhao) => !talhao.encerrado).toList();

  List<Talhao> get talhoesEncerrados =>
      _todosTalhoes.where((talhao) => talhao.encerrado).toList();

  final _service = ServicesTalhao();

  Future<void> carregarTalhoes(int idPropriedade) {
    _idPropriedadeAtual = idPropriedade;
    _paginaAtual = 1;
    _temMaisPaginas = true;

    return cargaPrincipal.executar(
      chamada: () async {
        final novosTalhoes = await _service.buscarPorPropriedade(
          idPropriedade,
          pagina: _paginaAtual,
        );

        _todosTalhoes = novosTalhoes;

        if (novosTalhoes.length < ServicesTalhao.limitePorPagina) {
          _temMaisPaginas = false;
        }
      },
      aoFalhar: () {},
    );
  }

  Future<void> carregarMaisTalhoes() {
    if (_cargaMais.isLoading || !_temMaisPaginas || _idPropriedadeAtual == null) {
      return Future.value();
    }

    return _cargaMais.executar(
      chamada: () async {
        final proximaPagina = _paginaAtual + 1;
        final novosTalhoes = await _service.buscarPorPropriedade(
          _idPropriedadeAtual!,
          pagina: proximaPagina,
        );

        if (novosTalhoes.isEmpty) {
          _temMaisPaginas = false;
          return;
        }

        _paginaAtual = proximaPagina;
        _todosTalhoes.addAll(novosTalhoes);

        if (novosTalhoes.length < ServicesTalhao.limitePorPagina) {
          _temMaisPaginas = false;
        }
      },
      aoFalhar: () {},
    );
  }
}
