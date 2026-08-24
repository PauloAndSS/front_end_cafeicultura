import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class EntrarViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final ServicesAuth _service;

  EntrarViewModel({required ServicesAuth service}) : _service = service;

  Future<bool> fazerLogin(
    String entradaBruta,
    String senha,
    SessionViewModel session,
  ) {
    return cargaPrincipal.executar(
      chamada: () async {
        final credencial = Credencial(
          identificacao: IdentificacaoLogin.criar(entradaBruta),
          senha: senha,
        );

        final resposta = await _service.autenticar(LoginRequestDTO(
          entrada: credencial.valorEntrada,
          senha: credencial.senha,
          tipoEntrada: credencial.tipoEntrada,
        ));

        final id = resposta.sessaoAtiva?.idUsuario;

        if (id == null) {
          throw Exception('ID do usuário não retornado pelo servidor.');
        }

        await session.login(id, resposta.sessaoAtiva?.nome ?? 'Produtor');

        return true;
      },
      aoFalhar: () => false,
    );
  }
}
