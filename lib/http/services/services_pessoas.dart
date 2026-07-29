import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:http/http.dart' as http;
class ServicesFornecedor extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/fornecedores');
  Future<Fornecedor> cadastrar(Fornecedor fornecedor) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(fornecedor.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Fornecedor.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? jsonResponse['mensagem'] ?? 'Erro ao cadastrar fornecedor.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}

class ServicesFuncionario extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/funcionarios');

  Future<Funcionario> cadastrar(Funcionario funcionario) async {
    try {
      final response = await http.post(
        Uri.parse('$url'), 
        headers: defaultHeaders,
        body: jsonEncode(funcionario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Funcionario.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? jsonResponse['mensagem'] ?? 'Erro ao cadastrar funcionário.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}

// ==========================================
// SERVIÇO DE CLIENTE
// ==========================================
class ServicesCliente extends BaseService {
    late final Uri url = Uri.parse('$baseUrl/clientes');
  Future<Cliente> cadastrar(Cliente cliente) async {
    try {
      final response = await http.post(
        Uri.parse('$url'), 
        headers: defaultHeaders,
        body: jsonEncode(cliente.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Cliente.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? jsonResponse['mensagem'] ?? 'Erro ao cadastrar cliente.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}

// ==========================================
// SERVIÇO DE MEEIRO
// ==========================================
class ServicesMeeiro extends BaseService {
    late final Uri url = Uri.parse('$baseUrl/meeiros');
  Future<Meeiro> cadastrar(Meeiro meeiro) async {
    try {
      final response = await http.post(
        Uri.parse('$url'), 
        headers: defaultHeaders,
        body: jsonEncode(meeiro.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Meeiro.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? jsonResponse['mensagem'] ?? 'Erro ao cadastrar meeiro.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}

// ==========================================
// SERVIÇO DE PRESTADOR DE SERVIÇO
// ==========================================
class ServicesPrestadorDeServico extends BaseService {
    late final Uri url = Uri.parse('$baseUrl/prestadores');
  Future<PrestadorDeServico> cadastrar(PrestadorDeServico prestador) async {
    try {
      final response = await http.post(
        Uri.parse('$url'), 
        headers: defaultHeaders,
        body: jsonEncode(prestador.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return PrestadorDeServico.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? jsonResponse['mensagem'] ?? 'Erro ao cadastrar prestador de serviço.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}