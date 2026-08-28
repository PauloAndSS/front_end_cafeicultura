import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

const List<TipoPapel> categoriasDeResponsavel = [
  TipoPapel.funcionario,
  TipoPapel.meeiro,
  TipoPapel.prestador,
];

class _EstadoDaCategoria {
  final List<PapelPessoa> pessoas = [];

  final EstadoDeCarga carga;
  final EstadoDeCarga cargaMais;

  int pagina = 1;
  int totalPaginas = 1;
  bool carregada = false;

  _EstadoDaCategoria._(this.carga, this.cargaMais);

  factory _EstadoDaCategoria(VoidCallback aoMudar) {
    final carga = EstadoDeCarga(aoMudar: aoMudar);

    return _EstadoDaCategoria._(
      carga,
      EstadoDeCarga(aoMudar: aoMudar, erroCompartilhadoCom: carga),
    );
  }
}

mixin CarregarPessoasMixin on NotificaSeVivoMixin {
  static const int _limitePorPagina = 20;

  static const int _maxPaginas = 50;

  final Map<TipoPapel, _EstadoDaCategoria> _categorias = {};

  _EstadoDaCategoria _estadoDe(TipoPapel papel) => _categorias.putIfAbsent(
        papel,
        () => _EstadoDaCategoria(notificarSeVivo),
      );

  List<PapelPessoa> pessoasDe(TipoPapel papel) =>
      List.unmodifiable(_estadoDe(papel).pessoas);

  bool categoriaCarregada(TipoPapel papel) => _estadoDe(papel).carregada;

  bool isCarregando(TipoPapel papel) => _estadoDe(papel).carga.isLoading;

  bool isCarregandoMais(TipoPapel papel) => _estadoDe(papel).cargaMais.isLoading;

  String? mensagemErroDe(TipoPapel papel) => _estadoDe(papel).carga.mensagemErro;

  bool temMaisDe(TipoPapel papel) {
    final estado = _estadoDe(papel);

    return estado.pagina < estado.totalPaginas && estado.pagina < _maxPaginas;
  }

  List<PapelPessoa> get responsaveis => List.unmodifiable(
        categoriasDeResponsavel.expand((papel) => _estadoDe(papel).pessoas),
      );

  Future<void> carregarCategoria(TipoPapel papel, {bool recarregar = false}) {
    final estado = _estadoDe(papel);

    if (estado.carga.isLoading || estado.cargaMais.isLoading) {
      return Future.value();
    }

    if (estado.carregada && !recarregar) return Future.value();

    return estado.carga.executar(
      chamada: () async {
        final resultado = await servicoDoPapel(papel)
            .listar(pagina: 1, limite: _limitePorPagina);

        estado.pagina = resultado.pagina;
        estado.totalPaginas = resultado.totalPaginas;
        estado.pessoas
          ..clear()
          ..addAll(_comIdentificacao(resultado.data));
        estado.carregada = true;
      },
      aoFalhar: () {},
    );
  }

  Future<void> carregarMaisDe(TipoPapel papel) {
    final estado = _estadoDe(papel);

    if (estado.carga.isLoading ||
        estado.cargaMais.isLoading ||
        !temMaisDe(papel)) {
      return Future.value();
    }

    final proximaPagina = estado.pagina + 1;

    return estado.cargaMais.executar(
      chamada: () async {
        final resultado = await servicoDoPapel(papel)
            .listar(pagina: proximaPagina, limite: _limitePorPagina);

        estado.pagina = proximaPagina;
        estado.totalPaginas = resultado.totalPaginas;
        estado.pessoas.addAll(_comIdentificacao(resultado.data));
      },
      aoFalhar: () {},
    );
  }

  /// Os fornecedores prontos, para a guarda "não há fornecedor cadastrado"
  /// que antecede os diálogos de insumo. A seleção do beneficiado não passa
  /// por aqui: ela navega o catálogo pelo próprio mixin.
  Future<List<Pessoa>> carregarFornecedores() async {
    await carregarCategoria(TipoPapel.fornecedor);

    return pessoasDe(TipoPapel.fornecedor)
        .map((papel) => papel.pessoa)
        .toList();
  }

  List<PapelPessoa> _comIdentificacao(List<PapelPessoa> pagina) =>
      pagina.where((papel) => papel.id != null).toList();
}
