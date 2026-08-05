import 'dart:convert';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:http/http.dart' as http;
import 'services.dart';
import '../dtos/auth_dto.dart';

class ServicesAuth extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/auth');

  Future<LoginResponseDTO> autenticar(LoginRequestDTO dto) async {
    try {
      final response = await http.post(
        Uri.parse('$url/autenticar'),
        headers: defaultHeaders,
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        BaseService.atualizarCookie(response);
        final dadosAuth = extrairDadosResposta(response.bodyBytes);
        return LoginResponseDTO.fromJson(dadosAuth);
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao autenticar. Verifique seus dados.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao tentar fazer login. Tente novamente mais tarde.');
    }
  }

  Future<void> sair() async {
    try {
      final response = await http.post(
        Uri.parse('$url/logout'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        BaseService.sessionCookie = null;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao sair. Verifique sua conexão.',
        );
      }
    } catch (e) {
      throw ApiException('Aviso: Falha ao contatar servidor para sair. Tente novamente mais tarde.');
    }
  }
}
