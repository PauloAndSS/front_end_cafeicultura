import 'package:flutter/material.dart';

class CadastrarViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> realizarCadastro({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // await _authRepository.cadastrarUsuario(nome, email, senha);
      
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}