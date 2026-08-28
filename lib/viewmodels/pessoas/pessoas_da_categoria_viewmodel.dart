import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class PessoasDaCategoriaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  static const int _limite = 20;

  final TipoPapel papel;

  final ServicePapelPessoa<PapelPessoa> _service;

  PessoasDaCategoriaViewModel(this.papel,
      {ServicePapelPessoa<PapelPessoa>? service})
      : _service = service ?? servicoDoPapel(papel);

  late final EstadoDeCarga _cargaMais = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  final List<PapelPessoa> _pessoas = [];

  int _paginaAtual = 1;
  int _totalPaginas = 1;
  bool _carregado = false;

  List<PapelPessoa> get pessoas => List.unmodifiable(_pessoas);

  bool get carregado => _carregado;

  bool get isLoadingMore => _cargaMais.isLoading;

  bool get temMais => _paginaAtual < _totalPaginas;

  Future<void> carregar() {
    if (isLoading || _cargaMais.isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final resultado = await _service.listar(pagina: 1, limite: _limite);

        _paginaAtual = resultado.pagina;
        _totalPaginas = resultado.totalPaginas;
        _pessoas
          ..clear()
          ..addAll(_comIdentificacao(resultado.data));
        _carregado = true;
      },
      aoFalhar: () {},
    );
  }

  Future<void> carregarMais() {
    if (isLoading || _cargaMais.isLoading || !temMais) return Future.value();

    final proximaPagina = _paginaAtual + 1;

    return _cargaMais.executar(
      chamada: () async {
        final resultado =
            await _service.listar(pagina: proximaPagina, limite: _limite);

        _paginaAtual = proximaPagina;
        _totalPaginas = resultado.totalPaginas;
        _pessoas.addAll(_comIdentificacao(resultado.data));
      },
      aoFalhar: () {},
    );
  }

  List<PapelPessoa> _comIdentificacao(List<PapelPessoa> pagina) =>
      pagina.where((papel) => papel.id != null).toList();
}
