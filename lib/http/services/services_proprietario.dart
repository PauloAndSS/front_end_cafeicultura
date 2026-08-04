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
        final cadastroResponse = extrairDadosResposta(response.bodyBytes);
        return CadastroProprietarioResponseDTO.fromJson(cadastroResponse);
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao cadastrar proprietário. Tente novamente mais tarde.');
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
      }else{
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar endereço do proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao cadastrar endereço do proprietário. Tente novamente mais tarde.');
    }
  }

  //getters
Future<Proprietario> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    
    try {
      final response = await http.get(
        urlGet,
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dadosProprietario = extrairDadosResposta(response.bodyBytes);
        return Proprietario.fromJson(dadosProprietario);
      } else if (response.statusCode == 404) {
        throw ApiException('Proprietário não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do proprietário.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar dados do proprietário. Tente novamente mais tarde.');
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
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar endereço do proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar endereço do proprietário. Tente novamente mais tarde.');
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
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar e-mail do proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar e-mail do proprietário. Tente novamente mais tarde.');
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
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar telefone do proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar telefone do proprietário. Tente novamente mais tarde.');
    }
  }

  Future<bool> atualizarIdentificacao({
    required int id,
    String? nome,
    String? razaoSocial,
  }) async {
    final uri = Uri.parse('$url/$id/identificacao');

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
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar dados do proprietário.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar dados do proprietário. Tente novamente mais tarde.');
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
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar inscrição estadual.',
        );
      }
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar inscrição estadual. Tente novamente mais tarde.');
    }
  }
}
