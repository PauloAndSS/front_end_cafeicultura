import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class TalhoesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _mensagemErro;
  List<Talhao> _todosTalhoes = [];

  bool get isLoading => _isLoading;
  String? get mensagemErro => _mensagemErro;
  
  List<Talhao> get talhoes => _todosTalhoes;

  List<Talhao> get talhoesAtivos => 
      _todosTalhoes.where((t) => t.dataFim == null).toList();

  List<Talhao> get talhoesEncerrados => 
      _todosTalhoes.where((t) => t.dataFim != null).toList();

  final _service = ServicesTalhao();

  Future<void> carregarTalhoes(int idPropriedade) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _todosTalhoes = await _service.buscarTodosTalhoesPorPropriedade(idPropriedade);
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro de conexão ao carregar talhões.';
      debugPrint('Erro no carregamento dos talhões: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparDados() {
    _todosTalhoes = [];
    _mensagemErro = null;
    notifyListeners();
  }

  void escutarIsLoggedIn(SessionViewModel session) {
    session.addListener(() {
      if (!session.isLoggedIn) {
        limparDados(); 
      }
    });
  }
}