import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';

class PropriedadesUsuarioViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _mensagemErro;
  List<Propriedade> _propriedades = [];
  int? _idPropriedadeSelecionada;

  bool get isLoading => _isLoading;
  String? get mensagemErro => _mensagemErro;
  List<Propriedade> get propriedades => _propriedades;
  int? get idPropriedadeSelecionada => _idPropriedadeSelecionada;

  final _service = ServicesPropriedade();

  Future<void> carregarPropriedades() async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _propriedades = await _service.buscarPorProprietario();

      if (_propriedades.isNotEmpty) {
        //se propriedade selecionada for nula
        final aindaExiste = _propriedades.any(
          (p) => p.id == _idPropriedadeSelecionada,
        );

        if (_idPropriedadeSelecionada == null || !aindaExiste) {
          _idPropriedadeSelecionada = _propriedades.first.id;
        }
      } else {
        _idPropriedadeSelecionada = null;
      }
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro =
          'Ocorreu um erro interno no aplicativo. Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selecionarPropriedade(int idPropriedade) {
    _idPropriedadeSelecionada = idPropriedade;

    final index = _propriedades.indexWhere((p) => p.id == idPropriedade);

    if (index > 0) {
      final propriedadeEscolhida = _propriedades.removeAt(index);
      _propriedades.insert(0, propriedadeEscolhida);
    }

    notifyListeners();
  }

  void adicionarPropriedadeLocal(Propriedade novaPropriedade) {
    _propriedades.insert(0, novaPropriedade);
    _idPropriedadeSelecionada = novaPropriedade.id;

    notifyListeners();
  }

}
