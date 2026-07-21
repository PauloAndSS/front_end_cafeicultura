import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:http/http.dart' as http;
class ServicesPropriedade extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/propriedade');

Future<Propriedade> cadastrar(Propriedade propriedade) async {
    try {
      final response = await http.post(
        Uri.parse('$url/'),
        headers: defaultHeaders,
        body: jsonEncode(propriedade.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Propriedade.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao cadastrar propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<Propriedade> buscarPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$url/$id'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return Propriedade.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao buscar propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarNome(int id, String novoNome) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$id/nome'),
        headers: defaultHeaders,
        body: jsonEncode({'nome': novoNome}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao atualizar nome da propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarTamanho(int id, Tamanho tamanho) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$id/tamanho'),
        headers: defaultHeaders,
        body: jsonEncode({'tamanho': tamanho.toJson()}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao atualizar tamanho da propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarEndereco(int id, Endereco endereco) async {
    try {
      final response = await http.patch(
        Uri.parse('$url/$id/endereco'),
        headers: defaultHeaders,
        body: jsonEncode({'endereco': endereco.toJson()}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao atualizar endereço da propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<List<Propriedade>> buscarPorProprietario(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$url/proprietario/$idUsuario'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        return jsonList.map((json) => Propriedade.fromJson(json)).toList();
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['error'] ?? 
                    jsonResponse['mensagem'] ?? 
                    'Erro ao buscar suas propriedades.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}