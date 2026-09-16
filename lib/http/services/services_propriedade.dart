import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:http/http.dart' as http;

class ServicesPropriedade extends BaseService {
  @override
  String get recurso => 'propriedades';

  Future<bool> cadastrar(Propriedade propriedade) {
    return executarRequisicao(
      enviar: () => http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(propriedade.toJson()),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar propriedade.',
      acao: 'cadastrar propriedade',
    );
  }

  Future<Propriedade> buscarPorId(int id) {
    return executarRequisicao(
      enviar: () => http.get(rota('$id'), headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Propriedade.fromJson),
      erroMsg: 'Erro ao buscar propriedade.',
      acao: 'buscar propriedade',
    );
  }

  Future<List<Propriedade>> buscarPorProprietario() {
    return executarRequisicao(
      enviar: () => http.get(rota('proprietario'), headers: defaultHeaders),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Propriedade.fromJson),
      // Proprietário sem nenhuma propriedade: o backend responde 404 com
      // corpo JSON. É o estado de quem acabou de se cadastrar, não um erro.
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar propriedades.',
      acao: 'buscar propriedades',
    );
  }

  Future<bool> atualizarNome(int id, String novoNome) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$id/nome'),
        headers: defaultHeaders,
        body: jsonEncode({'nome': novoNome}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar nome da propriedade.',
      acao: 'atualizar nome da propriedade',
    );
  }

  Future<bool> atualizarTamanho(int id, Tamanho tamanho) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$id/tamanho'),
        headers: defaultHeaders,
        body: jsonEncode({'tamanho': tamanho.toJson()}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar tamanho da propriedade.',
      acao: 'atualizar tamanho da propriedade',
    );
  }

  Future<bool> atualizarEndereco(int id, Endereco endereco) {
    return executarRequisicao(
      enviar: () => http.patch(
        rota('$id/endereco'),
        headers: defaultHeaders,
        body: jsonEncode({'endereco': endereco.toJson()}),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar endereço da propriedade.',
      acao: 'atualizar endereço da propriedade',
    );
  }

  Future<bool> excluir(int id) {
    return executarRequisicao(
      enviar: () => http.delete(rota('$id'), headers: defaultHeaders),
      aoSucesso: (_) => true,
      errosPorStatus: {
        403: 'Propriedade possui talhões e/ou safras cadastradas nela e não pode ser excluida.',
      },
      erroMsg: 'Erro ao excluir propriedade.',
      acao: 'excluir propriedade',
    );
  }
}
