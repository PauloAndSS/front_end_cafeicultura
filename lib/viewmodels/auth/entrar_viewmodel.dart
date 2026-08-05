import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';

class EntrarViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  final ServicesAuth _service;

  EntrarViewmodel({required ServicesAuth service}) : _service = service;

  // 👇 ASSINATURA CORRIGIDA: Apenas 3 argumentos (entradaBruta, senha, session)
  Future<bool> fazerLogin(String entradaBruta, String senha, SessionViewModel session) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final credencial = Credencial(identificacao: IdentificacaoLogin.criar(entradaBruta), senha: senha);
      final dto = LoginRequestDTO(
        entrada: credencial.valorEntrada, 
        senha: credencial.senha, 
        tipoEntrada: credencial.tipoEntrada
      );

      final resposta = await _service.autenticar(dto);
      
      final id = resposta.sessaoAtiva?.idUsuario;
      final nome = resposta.sessaoAtiva?.nome ?? 'Produtor';

      if (id == null) {
        throw Exception("ID do usuário não retornado pelo servidor.");
      }

      // Salva a sessão, o AuthWrapper vai notar isso e jogar o usuário para a MainScreenView
      await session.login(id, nome);

      return true;

    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno no aplicativo. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}