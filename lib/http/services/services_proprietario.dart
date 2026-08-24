import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/dtos/cadastro_proprietario_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:http/http.dart' as http;

class ServicesProprietario extends BaseService {
  @override
  String get recurso => 'proprietarios';

  Future<CadastroProprietarioResponseDTO> cadastrar({
    required Proprietario proprietario,
    required String senha,
  }) {
    final dto = CadastroProprietarioDTO(proprietario: proprietario, senha: senha);

    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(dto.cadastrar()),
      ),
      aoSucesso: (resposta) {
        BaseService.atualizarCookie(resposta);

        return extrairObjeto(
          resposta.bodyBytes,
          CadastroProprietarioResponseDTO.fromJson,
        );
      },
      erroMsg: 'Erro ao cadastrar proprietário.',
      acao: 'cadastrar proprietário',
    );
  }

  Future<bool> cadastrarEndereco({
    required int idProprietario,
    required Endereco endereco,
  }) {
    return executarRequisicao(
      enviar: () => http.post(
        rota('$idProprietario/endereco'),
        headers: defaultHeaders,
        body: jsonEncode(endereco.toJson()),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar endereço do proprietário.',
      acao: 'cadastrar endereço do proprietário',
    );
  }

  Future<Proprietario> buscarPorId(int id) {
    return executarRequisicao(
      enviar: () => http.get(rota('$id'), headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Proprietario.fromJson),
      errosPorStatus: {404: 'Proprietário não encontrado.'},
      erroMsg: 'Erro ao buscar dados do proprietário.',
      acao: 'buscar dados do proprietário',
    );
  }

  Future<bool> atualizarEndereco(int id, Endereco endereco) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/endereco'),
        headers: defaultHeaders,
        body: jsonEncode(endereco.toJson()),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar endereço do proprietário.',
      acao: 'atualizar endereço do proprietário',
    );
  }

  Future<bool> atualizarEmail(int id, String email) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/email'),
        headers: defaultHeaders,
        body: jsonEncode({'email': email}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar e-mail do proprietário.',
      acao: 'atualizar e-mail do proprietário',
    );
  }

  Future<bool> atualizarTelefone(int id, String telefone) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/telefone'),
        headers: defaultHeaders,
        body: jsonEncode({'telefone': telefone}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar telefone do proprietário.',
      acao: 'atualizar telefone do proprietário',
    );
  }

  Future<bool> atualizarIdentificacao({
    required int id,
    String? nome,
    String? razaoSocial,
  }) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/identificacao'),
        headers: defaultHeaders,
        body: jsonEncode({
          if (nome != null) 'nome': nome,
          if (razaoSocial != null) 'razaoSocial': razaoSocial,
        }),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar dados do proprietário.',
      acao: 'atualizar dados do proprietário',
    );
  }

  Future<bool> atualizarInscricaoEstadual({
    required int id,
    required String inscEstadual,
    required String cnpj,
  }) {
    return executarRequisicao(
      enviar: () => http.put(
        rota('$id/inscricao-estadual'),
        headers: defaultHeaders,
        body: jsonEncode({
          'inscricaoEstadual': inscEstadual,
          'cnpj': cnpj,
        }),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar inscrição estadual.',
      acao: 'atualizar inscrição estadual',
    );
  }
}
