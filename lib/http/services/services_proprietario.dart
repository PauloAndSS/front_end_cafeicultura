import 'dart:convert';
import 'package:frond_end_cafeicultura_mobile/http/dtos/cadastro_proprietario_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:http/http.dart' as http;

class ServicesProprietario extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/proprietarios');

  // CADASTROS
  Future<CadastroProprietarioResponseDTO> cadastrar({
    required Proprietario proprietario,
    required String senha,
  }) async {
    final dto = CadastroProprietarioDTO(
      proprietario: proprietario,
      senha: senha,
    );
    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(dto.cadastrar()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        BaseService.atualizarCookie(response);

        return CadastroProprietarioResponseDTO.fromJson(
          jsonDecode(response.body),
        );
      } else {
        final corpoDecodificado = jsonDecode(response.body);

        if (corpoDecodificado.containsKey('erros') &&
            corpoDecodificado['erros'] is List) {
          final List errosLista = corpoDecodificado['erros'];

          final mensagensBrutas = errosLista
              .map((e) => e['msg'].toString())
              .toList();

          throw ApiValidationException(mensagensBrutas);
        } else {
          final msg =
              corpoDecodificado['error'] ??
              corpoDecodificado['mensagem'] ??
              'Erro desconhecido no servidor.';
          throw ApiException(msg);
        }
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> cadastrarEndereco({
    required int idProprietario,
    required Endereco endereco,
  }) async {
    final urlEndereco = Uri.parse('$url/$idProprietario/endereco');

    try {
      final response = await http.post(
        urlEndereco,
        headers: defaultHeaders,
        body: jsonEncode(endereco.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      final corpoDecodificado = jsonDecode(response.body);
      final msg =
          corpoDecodificado['error'] ??
          corpoDecodificado['mensagem'] ??
          'Erro desconhecido no servidor.';
      throw ApiException(msg);
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  //getters
  Future<Proprietario> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');

    final response = await http.get(
      urlGet,
      headers: defaultHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      return Proprietario.fromJson(jsonResponse); 
    } else if (response.statusCode == 404) {
      throw ApiException('Proprietário não encontrado.');
    } else {
      throw ApiException('Erro ao buscar dados: ${response.statusCode}');
    }
  }


  //updates
  Future<bool> atualizarEndereco(int id, Endereco endereco) async {
    final uri = Uri.parse('$url/$id/endereco');

    try {
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(endereco.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      final corpoDecodificado = jsonDecode(response.body);

      if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
        final List errosLista = corpoDecodificado['erros'];
        throw ApiValidationException(errosLista.map((e) => e['msg'].toString()).toList());
      } else {
        final msg = corpoDecodificado['error'] ?? corpoDecodificado['mensagem'] ?? 'Erro desconhecido no servidor.';
        throw ApiException(msg);
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarEmail(int id, String email) async {
    final uri = Uri.parse('$url/$id/email');

    try {
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      final corpoDecodificado = jsonDecode(response.body);

      if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
        final List errosLista = corpoDecodificado['erros'];
        throw ApiValidationException(errosLista.map((e) => e['msg'].toString()).toList());
      } else {
        final msg = corpoDecodificado['error'] ?? corpoDecodificado['mensagem'] ?? 'Erro desconhecido no servidor.';
        throw ApiException(msg);
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarTelefone(int id, String telefone) async {
    final uri = Uri.parse('$url/$id/telefone');

    try {
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({'telefone': telefone}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      final corpoDecodificado = jsonDecode(response.body);

      if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
        final List errosLista = corpoDecodificado['erros'];
        throw ApiValidationException(errosLista.map((e) => e['msg'].toString()).toList());
      } else {
        final msg = corpoDecodificado['error'] ?? corpoDecodificado['mensagem'] ?? 'Erro desconhecido no servidor.';
        throw ApiException(msg);
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarIdentificacao({
    required int id,
    String? nome,
    String? razaoSocial,
  }) async {
    final uri = Uri.parse('$url/$id/identificacao');

    // Monta o JSON apenas com os campos que foram preenchidos
    final Map<String, dynamic> requestBody = {};
    if (nome != null) requestBody['nome'] = nome;
    if (razaoSocial != null) requestBody['razaoSocial'] = razaoSocial;

    try {
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      final corpoDecodificado = jsonDecode(response.body);

      if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
        final List errosLista = corpoDecodificado['erros'];
        throw ApiValidationException(errosLista.map((e) => e['msg'].toString()).toList());
      } else {
        final msg = corpoDecodificado['error'] ?? corpoDecodificado['mensagem'] ?? 'Erro desconhecido no servidor.';
        throw ApiException(msg);
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> atualizarInscricaoEstadual({
    required int id,
    required String inscEstadual,
    required String cnpj,
  }) async {
    final uri = Uri.parse('$url/$id/inscricao-estadual');

    try {
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'inscricaoEstadual': inscEstadual,
          'cnpj': cnpj,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      final corpoDecodificado = jsonDecode(response.body);
      if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
        final List errosLista = corpoDecodificado['erros'];
        throw ApiValidationException(errosLista.map((e) => e['msg'].toString()).toList());
      } else {
        final msg = corpoDecodificado['error'] ?? corpoDecodificado['mensagem'] ?? 'Erro desconhecido.';
        throw ApiException(msg);
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}
