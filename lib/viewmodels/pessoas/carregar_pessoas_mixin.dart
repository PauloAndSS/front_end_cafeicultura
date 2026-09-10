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

  bool carregada = false;

  _EstadoDaCategoria(VoidCallback aoMudar)
      : carga = EstadoDeCarga(aoMudar: aoMudar);
}

mixin CarregarPessoasMixin on NotificaSeVivoMixin {
  final Map<TipoPapel, _EstadoDaCategoria> _categorias = {};

  _EstadoDaCategoria _estadoDe(TipoPapel papel) => _categorias.putIfAbsent(
        papel,
        () => _EstadoDaCategoria(notificarSeVivo),
      );

  List<PapelPessoa> pessoasDe(TipoPapel papel) =>
      List.unmodifiable(_estadoDe(papel).pessoas);

  bool categoriaCarregada(TipoPapel papel) => _estadoDe(papel).carregada;

  bool isCarregando(TipoPapel papel) => _estadoDe(papel).carga.isLoading;

  String? mensagemErroDe(TipoPapel papel) => _estadoDe(papel).carga.mensagemErro;

  List<PapelPessoa> get responsaveis => List.unmodifiable(
        categoriasDeResponsavel.expand((papel) => _estadoDe(papel).pessoas),
      );

  Future<void> carregarCategoria(TipoPapel papel, {bool recarregar = false}) {
    final estado = _estadoDe(papel);

    if (estado.carga.isLoading) return Future.value();

    if (estado.carregada && !recarregar) return Future.value();

    return estado.carga.executar(
      chamada: () async {
        final encontrados = await servicoDoPapel(papel).listar();

        estado.pessoas
          ..clear()
          ..addAll(_comIdentificacao(encontrados));
        estado.carregada = true;
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

  List<PapelPessoa> _comIdentificacao(List<PapelPessoa> lista) =>
      lista.where((papel) => papel.id != null).toList();
}
