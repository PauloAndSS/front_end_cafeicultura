import 'dart:convert';

import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:http/http.dart' as http;

class ServicesAuth extends BaseService {
  @override
  String get recurso => 'auth';

  Future<LoginResponseDTO> autenticar(LoginRequestDTO dto) {
    return executarRequisicao(
      enviar: () => http.post(
        rota('autenticar'),
        headers: defaultHeaders,
        body: jsonEncode(dto.toJson()),
      ),
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
      enviar: () => http.post(rota('logout'), headers: defaultHeaders),
      aoSucesso: (_) => BaseService.sessionCookie = null,
      erroMsg: 'Erro ao sair. Verifique sua conexão.',
      acao: 'sair',
    );
  }
}
