// lib/http/services/services_auth.dart

import 'dart:convert';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:http/http.dart' as http;
import 'services.dart'; 
import '../dtos/auth_dto.dart';

class ServicesAuth extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/auth');

  Future<LoginResponseDTO> autenticar(LoginRequestDTO dto) async {
    final response = await http.post(
      Uri.parse('$url/autenticar') ,
      headers: defaultHeaders,
      body: jsonEncode(dto.toJson()),
    );

    final rawCookie = response.headers['set-cookie'];
    print(response.headers);
    if (rawCookie != null) {
      final cookieSession = rawCookie.split(';')[0];
      BaseService.sessionCookie = cookieSession; 
    }

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return LoginResponseDTO.fromJson(jsonResponse); 
    } else {
      throw ApiException(jsonResponse['mensagem']);
    }
  }

  Future<void> sair() async {
    print('Headers sendo enviados: $defaultHeaders');
    final response = await http.post(
      Uri.parse('$url/logout'),
      headers: defaultHeaders,
    );

    BaseService.sessionCookie = null;
    
    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Erro ao encerrar sessão no servidor');
    }
  }
}