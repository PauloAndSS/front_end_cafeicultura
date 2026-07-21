import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class EntrarViewmodel extends ChangeNotifier{
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  final ServicesAuth _service;

  EntrarViewmodel({required ServicesAuth service}) : _service = service;

  Future<bool> fazerLogin(String entradaBruta, String senha, SessionViewModel session, PropriedadesUsuarioViewModel propriedadesVM,) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final credencial = Credencial(identificacao: IdentificacaoLogin.criar(entradaBruta), senha: senha);
      final dto = LoginRequestDTO(entrada: credencial.valorEntrada, senha: credencial.senha, tipoEntrada: credencial.tipoEntrada);

      final resposta = await _service.autenticar(dto);
      
      final id = resposta.sessaoAtiva?.idUsuario;
      final nome = resposta.sessaoAtiva?.nome ?? 'Produtor';

      if (id == null) {
        throw Exception("ID do usuário não retornado pelo servidor.");
      }

      await session.login(id, nome);

      propriedadesVM.carregarPropriedades(session.idUsuario!);
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