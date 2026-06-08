import 'package:flutter/material.dart';

class SessionViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _ownerName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get ownerName => _ownerName;

  void loginMock(String name) {
    _isLoggedIn = true;
    _ownerName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _ownerName = '';
    notifyListeners();
  }
}