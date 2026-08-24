import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class CadastrarPessoaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  TipoPapel? _papelSelecionado;
  TipoPapel? get papelSelecionado => _papelSelecionado;

  late final Map<TipoPapel, dynamic> _services;

  CadastrarPessoaViewModel() {
    _services = {
      TipoPapel.funcionario: ServicesFuncionario(),
      TipoPapel.meeiro: ServicesMeeiro(),
      TipoPapel.fornecedor: ServicesFornecedor(),
      TipoPapel.prestador: ServicesPrestadorDeServico(),
      TipoPapel.cliente: ServicesCliente(),
    };
  }

  void selecionarPapel(TipoPapel? papel) {
    _papelSelecionado = papel;
    notificarSeVivo();
  }

  Future<bool> cadastrarPessoa({required dynamic objetoPapel}) {
    if (_papelSelecionado == null) {
      mensagemErro = 'Selecione o papel da pessoa.';
      notificarSeVivo();
      return Future.value(false);
    }

    return cargaPrincipal.executar(
      chamada: () async {
        await _services[_papelSelecionado!].cadastrar(objetoPapel);
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
