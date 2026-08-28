import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class _PaginasDoStatus<T> {
  _PaginasDoStatus(VoidCallback aoMudar)
      : cargaPrimeira = EstadoDeCarga(aoMudar: aoMudar) {
    cargaMais = EstadoDeCarga(
      aoMudar: aoMudar,
      erroCompartilhadoCom: cargaPrimeira,
    );
  }

  final EstadoDeCarga cargaPrimeira;

  late final EstadoDeCarga cargaMais;

  final List<T> itens = [];

  int ultimaPaginaCarregada = 0;

  int totalPaginas = 1;

  String? get mensagemErro => cargaPrimeira.mensagemErro;

  bool get vazio => ultimaPaginaCarregada == 0;

  bool get temMais => ultimaPaginaCarregada < totalPaginas;

  bool get ocupado => cargaPrimeira.isLoading || cargaMais.isLoading;

  void limpar() {
    itens.clear();
    ultimaPaginaCarregada = 0;
    totalPaginas = 1;
    cargaPrimeira.abandonar();
    cargaMais.abandonar();
  }
}

abstract class ListaAtividadesPaginadaViewModel<T extends EventoAgricola,
    E extends Object> extends ChangeNotifier with NotificaSeVivoMixin {
  late final Map<StatusEvento, _PaginasDoStatus<T>> _porStatus = {
    for (final filtro in StatusEvento.values)
      filtro: _PaginasDoStatus<T>(notificarSeVivo),
  };

  E? _escopo;

  int _geracao = 0;

  StatusEvento _statusAtual = StatusEvento.emAndamento;
  StatusEvento get statusAtual => _statusAtual;

  bool get isLoading => _paginasAtuais.cargaPrimeira.isLoading;

  bool get isCarregandoMais => _paginasAtuais.cargaMais.isLoading;

  String? get mensagemErro => _paginasAtuais.mensagemErro;

  List<T> get atividades => List.unmodifiable(_paginasAtuais.itens);

  bool get temMais => _paginasAtuais.temMais;

  _PaginasDoStatus<T> get _paginasAtuais => _porStatus[_statusAtual]!;

  @protected
  Future<ResultadoPaginadoDTO<T>> buscarPagina(
    E escopo,
    StatusEvento status,
    int pagina,
  );

  @protected
  Future<void>? prepararPrimeiraPagina(E escopo) => null;

  @protected
  Future<void> carregarEscopo(E escopo, {bool forcar = false}) async {
    if (_escopo != escopo) {
      _escopo = escopo;
      _limparTodos();
    }

    if (!forcar) {
      final paginas = _paginasAtuais;
      if (!paginas.vazio || paginas.mensagemErro != null) return;
    } else {
      _limparTodos();
    }

    await _carregarProximaPagina(primeira: true);
  }

  Future<void> selecionarStatus(StatusEvento status) async {
    if (status == _statusAtual) return;

    _statusAtual = status;
    notificarSeVivo();

    final paginas = _paginasAtuais;
    if (paginas.vazio && paginas.mensagemErro == null) {
      await _carregarProximaPagina(primeira: true);
    }
  }

  Future<void> carregarMaisPagina() {
    if (!_paginasAtuais.temMais) return Future.value();

    return _carregarProximaPagina(primeira: false);
  }

  Future<void> tentarNovamente() =>
      _carregarProximaPagina(primeira: _paginasAtuais.vazio);

  Future<void> recarregar() async {
    final escopo = _escopo;
    if (escopo == null) return;

    await carregarEscopo(escopo, forcar: true);
  }

  int _geracaoDoCacheVista = 0;

  void sincronizarCom(int geracaoDoCache) {
    if (geracaoDoCache == _geracaoDoCacheVista) return;

    _geracaoDoCacheVista = geracaoDoCache;
    recarregar();
  }

  Future<void> _carregarProximaPagina({required bool primeira}) {
    final escopo = _escopo;
    if (escopo == null) return Future.value();

    final status = _statusAtual;
    final paginas = _porStatus[status]!;

    if (paginas.ocupado) return Future.value();

    final pagina = paginas.ultimaPaginaCarregada + 1;
    final geracao = _geracao;

    final preparo = primeira ? prepararPrimeiraPagina(escopo) : null;

    final carga = primeira ? paginas.cargaPrimeira : paginas.cargaMais;

    return carga.executar(
      chamada: () async {
        final resultado = await buscarPagina(escopo, status, pagina);

        if (geracao == _geracao) {
          paginas.itens.addAll(resultado.data);
          paginas.ultimaPaginaCarregada = pagina;
          paginas.totalPaginas = resultado.totalPaginas;
        }
      },
      aoFalhar: () {},
      aindaVale: () => geracao == _geracao,
      aoFinalizar: () async {
        if (preparo != null) await preparo;
      },
    );
  }

  void _limparTodos() {
    _geracao++;

    for (final paginas in _porStatus.values) {
      paginas.limpar();
    }
  }
}

abstract class ListaAtividadesDaPropriedadePaginadaViewModel<
        T extends EventoAgricola>
    extends ListaAtividadesPaginadaViewModel<T, int> with CarregarTalhoesMixin {
  Future<void> carregar(int idPropriedade, {bool forcar = false}) =>
      carregarEscopo(idPropriedade, forcar: forcar);

  @override
  Future<void>? prepararPrimeiraPagina(int escopo) => carregarTalhoes(escopo);
}

abstract class ListaAtividadesDoTalhaoPaginadaViewModel<
        T extends EventoAgricola>
    extends ListaAtividadesPaginadaViewModel<T, (int idPropriedade, int idTalhao)> {
  Future<void> carregar(
    int idPropriedade,
    int idTalhao, {
    bool forcar = false,
  }) {
    return carregarEscopo((idPropriedade, idTalhao), forcar: forcar);
  }

  @override
  Future<ResultadoPaginadoDTO<T>> buscarPagina(
    (int idPropriedade, int idTalhao) escopo,
    StatusEvento status,
    int pagina,
  ) {
    return buscarNoTalhao(escopo.$1, escopo.$2, status, pagina);
  }

  @protected
  Future<ResultadoPaginadoDTO<T>> buscarNoTalhao(
    int idPropriedade,
    int idTalhao,
    StatusEvento status,
    int pagina,
  );
}
