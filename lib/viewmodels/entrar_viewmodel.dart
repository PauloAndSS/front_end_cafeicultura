import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';

class EntrarViewmodel extends ChangeNotifier{
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  int? _idUsuarioRecuperado;
  int? get idUsuarioRecuperado => _idUsuarioRecuperado;

  String? _nomeUsuarioRecuperado;
  String? get nomeUsuarioRecuperado => _nomeUsuarioRecuperado;

  final ServicesAuth _service;

  EntrarViewmodel({required ServicesAuth service}) : _service = service;

  Future<bool> fazerLogin(String entradaBruta, String senha) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final credencial = Credencial(identificacao: IdentificacaoLogin.criar(entradaBruta), senha: senha);
      final dto = LoginRequestDTO(entrada: credencial.valorEntrada, senha: credencial.senha, tipoEntrada: credencial.tipoEntrada);

      final resposta = await _service.autenticar(dto);
      
      _idUsuarioRecuperado = resposta.sessaoAtiva?['idUsuario'];
      _nomeUsuarioRecuperado = resposta.sessaoAtiva?['nome'];

      return true;

    } on ArgumentError catch (e) {
      _mensagemErro = e.message;
      return false;
    } on ApiException catch (e) {
      _mensagemErro = e.toString();
      return false;
    } catch (e) {
      _mensagemErro = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}