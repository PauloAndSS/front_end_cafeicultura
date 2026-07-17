import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _nomeUsuario = '';
  bool _isInitializing = true; 
  int? _idUsuario;

  bool get isLoggedIn => _isLoggedIn;
  String get nomeUsuario => _nomeUsuario;
  bool get isInitializing => _isInitializing;
  int? get idUsuario => _idUsuario;

  SessionViewModel() {
    _verificarSessaoSalva();
  }


  Future<void> _verificarSessaoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final idSalvo = prefs.getInt('id_usuario');
    final cookieSalvo = prefs.getString('cookie_sessao'); 

    if (idSalvo != null && cookieSalvo != null) {
      _isLoggedIn = true;
      _nomeUsuario = prefs.getString('nome_usuario') ?? 'Produtor';
      _idUsuario = idSalvo;
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
    _nomeUsuario = nome;
    _idUsuario = idUsuario;
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ServicesAuth().sair();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('id_usuario');
      await prefs.remove('nome_usuario');
      await prefs.remove('cookie_sessao'); 

      _isLoggedIn = false;
      _nomeUsuario = '';
      
      notifyListeners(); 
    
    } catch (e) {
      debugPrint('Logout no servidor falhou: $e');
    } 
      BaseService.sessionCookie = null;
  }

  Future<void> atualizarNomeUsuario(String novoNome) async {
    _nomeUsuario = novoNome;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', novoNome);
    
    notifyListeners(); 
  }
}