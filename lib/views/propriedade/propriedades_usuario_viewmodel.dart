import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';  
class PropriedadesUsuarioViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _mensagemErro;
  List<Propriedade> _propriedades = [];
  int? _idPropriedadeSelecionada;
  bool _dadosCarregados = false;

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

      _dadosCarregados = true;
      if (_propriedades.isNotEmpty) {
        //se propriedade selecionada for nula
        _idPropriedadeSelecionada ??= _propriedades.first.id;
      } else {
        _idPropriedadeSelecionada = null;
      }
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro de conexão ao carregar suas propriedades.';
      debugPrint('Erro no carregamento das propriedades: $e');
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
  
  void limparDados() {
    _propriedades = [];
    _mensagemErro = null;
    _dadosCarregados = false;
    notifyListeners();
  }

  
void escutarIsLoggedIn(SessionViewModel session) {
    if (session.isLoggedIn && !_dadosCarregados && !_isLoading) {
      carregarPropriedades();
    }

    session.addListener(() {
      if (!session.isLoggedIn) {
        limparDados();
      } else if (session.isLoggedIn && !_dadosCarregados && !_isLoading) {
        carregarPropriedades();
      }
    });
  }
}