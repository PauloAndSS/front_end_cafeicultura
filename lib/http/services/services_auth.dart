import 'dart:convert';
import 'package:flutter/foundation.dart';
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
        return LoginResponseDTO.fromJson(jsonDecode(response.body));
      } else {
        final jsonResponse = jsonDecode(response.body);
        
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro na autenticação. Verifique seus dados.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<void> sair() async {
    try {
      final response = await http.post(
        Uri.parse('$url/logout'),
        headers: defaultHeaders,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('Aviso: Servidor retornou código ${response.statusCode} ao tentar logout.');
      }
    } catch (e) {
      debugPrint('Aviso: Falha ao contatar servidor para logout: $e');
    } finally {
      BaseService.sessionCookie = null;
      debugPrint('🗑️ Sessão limpa do aplicativo com sucesso.');
    }
  }
}