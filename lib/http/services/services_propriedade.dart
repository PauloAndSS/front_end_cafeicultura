import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:http/http.dart' as http;
class ServicesPropriedade extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/propriedades');

Future<bool> cadastrar(Propriedade propriedade) async {
    try {
      final response = await http.post(
        Uri.parse('$url/'),
        headers: defaultHeaders,
        body: jsonEncode(propriedade.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao cadastrar propriedade. Tente novamente mais tarde.');
    }
  }

  //getters
  Future<Propriedade> buscarPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$url/$id'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final dadosPropriedade = extrairDadosResposta(response.bodyBytes); 
        return Propriedade.fromJson(dadosPropriedade);
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar propriedade. Tente novamente mais tarde.');
    }
  }

  Future<List<Propriedade>> buscarPorProprietario() async {
    try {
      final response = await http.get(
        Uri.parse('$url/proprietario'),
        headers: defaultHeaders,
      );
      if (response.statusCode == 200) {
        final dadosPropriedades = extrairDadosResposta(response.bodyBytes);
        return dadosPropriedades.map<Propriedade>((propriedade) => Propriedade.fromJson(propriedade)).toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar propriedades.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao buscar propriedades. Tente novamente mais tarde.');
    }
  }

  //updates
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
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar nome da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar nome da propriedade. Tente novamente mais tarde.');
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
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar tamanho da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar tamanho da propriedade. Tente novamente mais tarde.');
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
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao atualizar endereço da propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao atualizar endereço da propriedade. Tente novamente mais tarde.');
    }
  }

  //delete
  Future<bool> excluir(int id) async {
    final urlDelete = Uri.parse('$url/$id/');
    try {
      final response = await http.delete(urlDelete, headers: defaultHeaders);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if(response.statusCode == 403) {
        throw ApiException('Propriedade possui atividades e/ou despesas cadastradas e não pode ser excluida.');
      }else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao excluir propriedade.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação ao excluir propriedade. Tente novamente mais tarde.');
    }
  }
}