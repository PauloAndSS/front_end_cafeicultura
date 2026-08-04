import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:http/http.dart' as http;

class ServicesPessoa extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/pessoas');

  Future<List<PapelPessoa>> buscarPorProprietario() async {
    try {
      final response = await http.get(url, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final List<dynamic> dadosPessoas = extrairDadosResposta(response.bodyBytes);
        
        return dadosPessoas
            .map<PapelPessoa>((jsonItem) => PapelPessoaFactory.fromJson(jsonItem))
            .toList();
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar dados das pessoas. Tente novamente mais tarde.');
    }
  }
}

class ServicesFornecedor extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/fornecedores');

  Future<bool> cadastrar(Fornecedor fornecedor) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(fornecedor.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar fornecedor.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao cadastrar fornecedor. Tente novamente mais tarde.');
    }
  }

  Future<Fornecedor> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    try {
      final response = await http.get(urlGet, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final dadosFornecedor = extrairDadosResposta(response.bodyBytes);
        return Fornecedor.fromJson(dadosFornecedor);
      } else if (response.statusCode == 404) {
        throw ApiException('Fornecedor não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do fornecedor.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar fornecedor. Tente novamente mais tarde.');
    }
  }
}

class ServicesFuncionario extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/funcionarios');

  Future<bool> cadastrar(Funcionario funcionario) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(funcionario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar funcionário.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao cadastrar funcionário. Tente novamente mais tarde.');
    }
  }

  Future<Funcionario> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    try {
      final response = await http.get(urlGet, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final dadosFuncionario = extrairDadosResposta(response.bodyBytes);
        return Funcionario.fromJson(dadosFuncionario);
      } else if (response.statusCode == 404) {
        throw ApiException('Funcionário não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do funcionário.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar funcionário. Tente novamente mais tarde.');
    }
  }
}

// ==========================================
// SERVIÇO DE CLIENTE
// ==========================================
class ServicesCliente extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/clientes');

  Future<bool> cadastrar(Cliente cliente) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(cliente.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar cliente.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao cadastrar cliente. Tente novamente mais tarde.');
    }
  }

  Future<Cliente> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    try {
      final response = await http.get(urlGet, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final dadosCliente = extrairDadosResposta(response.bodyBytes);
        return Cliente.fromJson(dadosCliente);
      } else if (response.statusCode == 404) {
        throw ApiException('Cliente não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do cliente.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar cliente. Tente novamente mais tarde.');
    }
  }
}

// ==========================================
// SERVIÇO DE MEEIRO
// ==========================================
class ServicesMeeiro extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/meeiros');

  Future<bool> cadastrar(Meeiro meeiro) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(meeiro.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar Meeiro.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao cadastrar Meeiro. Tente novamente mais tarde.');
    }
  }

  Future<Meeiro> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    try {
      final response = await http.get(urlGet, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final dadosMeeiro = extrairDadosResposta(response.bodyBytes);
        return Meeiro.fromJson(dadosMeeiro);
      } else if (response.statusCode == 404) {
        throw ApiException('Meeiro não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do meeiro.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar meeiro. Tente novamente mais tarde.');
    }
  }
}

// ==========================================
// SERVIÇO DE PRESTADOR DE SERVIÇO
// ==========================================
class ServicesPrestadorDeServico extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/prestadores');

  Future<bool> cadastrar(PrestadorDeServico prestador) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(prestador.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao cadastrar prestador de serviço.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao cadastrar prestador de serviço. Tente novamente mais tarde.');
    }
  }

  Future<PrestadorDeServico> buscarPorId(int id) async {
    final urlGet = Uri.parse('$url/$id/');
    try {
      final response = await http.get(urlGet, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final dadosPrestador = extrairDadosResposta(response.bodyBytes);
        return PrestadorDeServico.fromJson(dadosPrestador);
      } else if (response.statusCode == 404) {
        throw ApiException('Prestador de serviço não encontrado.');
      } else {
        tratarErroRequisicao(
          response.bodyBytes,
          fallbackMsg: 'Erro ao buscar dados do prestador de serviço.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Falha na comunicação ao buscar prestador de serviço. Tente novamente mais tarde.');
    }
  }
}