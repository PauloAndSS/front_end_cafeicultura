import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _ownerName = '';
  bool _isInitializing = true; 

  bool get isLoggedIn => _isLoggedIn;
  String get ownerName => _ownerName;
  bool get isInitializing => _isInitializing;

  SessionViewModel() {
    _verificarSessaoSalva();
  }

  Future<void> _verificarSessaoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final idSalvo = prefs.getInt('id_usuario');
    final cookieSalvo = prefs.getString('cookie_sessao'); 

    if (idSalvo != null && cookieSalvo != null) {
      _isLoggedIn = true;
      _ownerName = prefs.getString('nome_usuario') ?? '';
      
      BaseService.sessionCookie = cookieSalvo; 
    }

    _isInitializing = false; 
    notifyListeners(); 
  }

  Future<void> login(int idUsuario, String nome) async {
    final prefs = await SharedPreferences.getInstance();
    
    final cookie = BaseService.sessionCookie ?? '';

    await prefs.setInt('id_usuario', idUsuario);
    await prefs.setString('nome_usuario', nome);
    await prefs.setString('cookie_sessao', cookie);

    _isLoggedIn = true;
    _ownerName = nome;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ServicesAuth().sair();
    } catch (e) {
      debugPrint('Logout no servidor falhou: $e');
    } finally {
      BaseService.sessionCookie = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('id_usuario');
      await prefs.remove('nome_usuario');
      await prefs.remove('cookie_sessao'); 

      _isLoggedIn = false;
      _ownerName = '';
      
      notifyListeners(); 
    }
  }
}