import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class PessoasDaCategoriaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final TipoPapel papel;

  final ServicePapelPessoa<PapelPessoa> _service;

  PessoasDaCategoriaViewModel(this.papel,
      {ServicePapelPessoa<PapelPessoa>? service})
      : _service = service ?? servicoDoPapel(papel);

  final List<PapelPessoa> _pessoas = [];

  bool _carregado = false;

  List<PapelPessoa> get pessoas => List.unmodifiable(_pessoas);

  bool get carregado => _carregado;

  Future<void> carregar() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final encontrados = await _service.listar();

        _pessoas
          ..clear()
          ..addAll(_comIdentificacao(encontrados));
        _carregado = true;
      },
      aoFalhar: () {},
    );
  }

  List<PapelPessoa> _comIdentificacao(List<PapelPessoa> lista) =>
      lista.where((papel) => papel.id != null).toList();
}
