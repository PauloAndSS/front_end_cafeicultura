import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/requisicao_http.dart';

class ServicesAuth extends BaseService {
  @override
  String get recurso => 'auth';

  Future<LoginResponseDTO> autenticar(LoginRequestDTO dto) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(rota('autenticar'), corpo: dto.toJson()),
      aoSucesso: (resposta) {
        BaseService.atualizarCookie(resposta);

        return extrairObjeto(resposta.bodyBytes, LoginResponseDTO.fromJson);
      },
      erroMsg: 'Erro ao autenticar. Verifique seus dados.',
      acao: 'tentar fazer login',
    );
  }

  Future<void> sair() {
    return executarRequisicao<void>(
      requisicao: RequisicaoHttp.post(rota('logout')),
      aoSucesso: (_) => BaseService.sessionCookie = null,
      erroMsg: 'Erro ao sair. Verifique sua conexão.',
      acao: 'sair',
    );
  }
}
