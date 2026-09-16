import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class CadastrarPessoaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final TipoPapel papel;

  final ServicePapelPessoa<PapelPessoa> _service;

  CadastrarPessoaViewModel(this.papel,
      {ServicePapelPessoa<PapelPessoa>? service})
      : _service = service ?? servicoDoPapel(papel);

  Future<bool> cadastrarPessoa(PapelPessoa objetoPapel) {
    return cargaPrincipal.executar(
      chamada: () async {
        await _service.cadastrar(objetoPapel);
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
