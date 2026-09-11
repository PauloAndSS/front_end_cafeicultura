import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _nomeUsuario = '';
  bool _isInitializing = true; 
  int? _idUsuario;

  bool _dadosProprietarioIncompletos = false;
  bool _enderecoIncompleto = false;

  bool get isLoggedIn => _isLoggedIn;
  String get nomeUsuario => _nomeUsuario;
  bool get isInitializing => _isInitializing;
  int? get idUsuario => _idUsuario;

  bool get dadosProprietarioIncompletos => _dadosProprietarioIncompletos;
  bool get enderecoIncompleto => _enderecoIncompleto;

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

      _dadosProprietarioIncompletos = prefs.getBool('dados_incompletos') ?? false;
      _enderecoIncompleto = prefs.getBool('endereco_incompleto') ?? false;
    }

    _isInitializing = false; 
    notifyListeners(); 
  }

  Future<void> login(int idUsuario, String nome, [bool dadosIncompletos = false, bool enderecoIncompleto = false]) async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = BaseService.sessionCookie ?? '';

    await prefs.setInt('id_usuario', idUsuario);
    await prefs.setString('nome_usuario', nome);
    await prefs.setString('cookie_sessao', cookie);

    await prefs.setBool('dados_incompletos', dadosIncompletos);
    await prefs.setBool('endereco_incompleto', enderecoIncompleto);
    _dadosProprietarioIncompletos = dadosIncompletos;
    _enderecoIncompleto = enderecoIncompleto;

    _isLoggedIn = true;
    _nomeUsuario = nome;
    _idUsuario = idUsuario;
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ServicesAuth().sair();
    } catch (e) {
      debugPrint('Logout no servidor falhou: $e');
    } 

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_usuario');
    await prefs.remove('nome_usuario');
    await prefs.remove('cookie_sessao'); 

    await prefs.remove('dados_incompletos');
    await prefs.remove('endereco_incompleto');
    _dadosProprietarioIncompletos = false;
    _enderecoIncompleto = false;

    _isLoggedIn = false;
    _nomeUsuario = '';
    _idUsuario = null;
    BaseService.sessionCookie = null;
      
    notifyListeners(); 
  }

  Future<void> atualizarNomeUsuario(String novoNome) async {
    _nomeUsuario = novoNome;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', novoNome);
    
    notifyListeners(); 
  }

  Future<void> atualizarStatusCadastro({bool dadosIncompletos = false, bool enderecoIncompleto = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    _dadosProprietarioIncompletos = dadosIncompletos;
    _enderecoIncompleto = enderecoIncompleto;
    
    await prefs.setBool('dados_incompletos', dadosIncompletos);
    await prefs.setBool('endereco_incompleto', enderecoIncompleto);
    
    notifyListeners();
  }
}