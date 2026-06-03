import 'package:flutter/material.dart';

class SessionViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _ownerName = '';

  // Getters para acessar os dados na interface
  bool get isLoggedIn => _isLoggedIn;
  String get ownerName => _ownerName;

  // Função para simular o login
  void loginMock(String name) {
    _isLoggedIn = true;
    _ownerName = name;
    notifyListeners(); // Avisa o Flutter para atualizar as telas
  }

  // Função para deslogar
  void logout() {
    _isLoggedIn = false;
    _ownerName = '';
    notifyListeners();
  }
}