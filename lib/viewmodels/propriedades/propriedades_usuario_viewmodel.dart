import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class PropriedadesUsuarioViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  List<Propriedade> _propriedades = [];
  int? _idPropriedadeSelecionada;

  List<Propriedade> get propriedades => _propriedades;
  int? get idPropriedadeSelecionada => _idPropriedadeSelecionada;

  Propriedade? get propriedadeSelecionada {
    if (_idPropriedadeSelecionada == null || _propriedades.isEmpty) return null;

    return _propriedades.firstWhere(
      (p) => p.id == _idPropriedadeSelecionada,
      orElse: () => _propriedades.first,
    );
  }

  String get nomeDaPropriedadeSelecionada =>
      propriedadeSelecionada?.nome ?? 'esta propriedade';

  final _service = ServicesPropriedade();

  Future<void> carregarPropriedades() => cargaPrincipal.executar(
        chamada: () async {
          _propriedades = await _service.buscarPorProprietario();
          _corrigirSelecao();
        },
        aoFalhar: () {},
      );

  void _corrigirSelecao() {
    if (_propriedades.isEmpty) {
      _idPropriedadeSelecionada = null;
      return;
    }

    final aindaExiste = _propriedades.any(
      (p) => p.id == _idPropriedadeSelecionada,
    );

    if (_idPropriedadeSelecionada == null || !aindaExiste) {
      _idPropriedadeSelecionada = _propriedades.first.id;
    }
  }

  void selecionarPropriedade(int idPropriedade) {
    _idPropriedadeSelecionada = idPropriedade;

    final index = _propriedades.indexWhere((p) => p.id == idPropriedade);

    if (index > 0) {
      final propriedadeEscolhida = _propriedades.removeAt(index);
      _propriedades.insert(0, propriedadeEscolhida);
    }

    notificarSeVivo();
  }

  void adicionarPropriedadeLocal(Propriedade novaPropriedade) {
    _propriedades.insert(0, novaPropriedade);
    _idPropriedadeSelecionada = novaPropriedade.id;

    notificarSeVivo();
  }
}
