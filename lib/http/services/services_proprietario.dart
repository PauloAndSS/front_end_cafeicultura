import 'package:frond_end_cafeicultura_mobile/http/dtos/cadastro_proprietario_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesProprietario extends BaseService {
  @override
  String get recurso => 'proprietarios';

  Future<CadastroProprietarioResponseDTO> cadastrar({
    required Proprietario proprietario,
    required String senha,
  }) {
    final dto = CadastroProprietarioDTO(proprietario: proprietario, senha: senha);

    return executarRequisicao(
      requisicao: RequisicaoHttp.post(url, corpo: dto.cadastrar()),
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
      requisicao: RequisicaoHttp.post(
        rota('$idProprietario/endereco'),
        corpo: endereco.toJson(),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao cadastrar endereço do proprietário.',
      acao: 'cadastrar endereço do proprietário',
    );
  }

  Future<Proprietario> buscarPorId(int id) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('$id')),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Proprietario.fromJson),
      errosPorStatus: {404: 'Proprietário não encontrado.'},
      erroMsg: 'Erro ao buscar dados do proprietário.',
      acao: 'buscar dados do proprietário',
    );
  }

  Future<bool> atualizarEndereco(int id, Endereco endereco) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.put(
        rota('$id/endereco'),
        corpo: endereco.toJson(),
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar endereço do proprietário.',
      acao: 'atualizar endereço do proprietário',
    );
  }

  Future<bool> atualizarEmail(int id, String email) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.put(
        rota('$id/email'),
        corpo: {'email': email},
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar e-mail do proprietário.',
      acao: 'atualizar e-mail do proprietário',
    );
  }

  Future<bool> atualizarTelefone(int id, String telefone) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.put(
        rota('$id/telefone'),
        corpo: {'telefone': telefone},
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
      requisicao: RequisicaoHttp.put(
        rota('$id/identificacao'),
        corpo: {
          'nome': ?nome,
          'razaoSocial': ?razaoSocial,
        },
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
      requisicao: RequisicaoHttp.put(
        rota('$id/inscricao-estadual'),
        corpo: {
          'inscricaoEstadual': inscEstadual,
          'cnpj': cnpj,
        },
      ),
      aoSucesso: (_) => true,
      erroMsg: 'Erro ao atualizar inscrição estadual.',
      acao: 'atualizar inscrição estadual',
    );
  }
}
