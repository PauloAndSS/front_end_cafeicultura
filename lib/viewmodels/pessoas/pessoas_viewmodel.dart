import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class PessoasViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  List<PapelPessoa> _todasPessoas = [];

  final ServicesPessoa _service;

  int _paginaAtual = 1;
  int _totalPaginas = 1;
  final int _limite = 20;

  late final EstadoDeCarga _cargaMais = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  bool get isLoadingMore => _cargaMais.isLoading;

  PessoasViewModel({ServicesPessoa? service})
      : _service = service ?? ServicesPessoa();

  // Getter que mapeia cada PapelPessoa para a entidade Pessoa correspondente
  List<Pessoa> get pessoas => _todasPessoas.map((p) => p.pessoa).toList();

  List<Funcionario> get funcionarios =>
      _todasPessoas.whereType<Funcionario>().toList();
  List<Meeiro> get meeiros => _todasPessoas.whereType<Meeiro>().toList();
  List<Cliente> get clientes => _todasPessoas.whereType<Cliente>().toList();
  List<Fornecedor> get fornecedores =>
      _todasPessoas.whereType<Fornecedor>().toList();
  List<PrestadorDeServico> get prestadores =>
      _todasPessoas.whereType<PrestadorDeServico>().toList();

  Future<void> carregarPessoas({bool recarregar = false}) {
    if (recarregar) {
      _paginaAtual = 1;
      _todasPessoas.clear();
    }

    if (isLoading || _cargaMais.isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final resultadoDTO = await _service.buscarPorProprietario(
          pagina: _paginaAtual,
          limite: _limite,
        );

        _todasPessoas = resultadoDTO.data;
        _totalPaginas = resultadoDTO.totalPaginas;
      },
      aoFalhar: () {},
    );
  }

  Future<void> carregarMaisPessoas() {
    if (_cargaMais.isLoading || isLoading || _paginaAtual >= _totalPaginas) {
      return Future.value();
    }

    final proximaPagina = _paginaAtual + 1;

    return _cargaMais.executar(
      chamada: () async {
        final resultadoDTO = await _service.buscarPorProprietario(
          pagina: proximaPagina,
          limite: _limite,
        );

        _paginaAtual = proximaPagina;
        _todasPessoas.addAll(resultadoDTO.data);
        _totalPaginas = resultadoDTO.totalPaginas;
      },
      aoFalhar: () {},
    );
  }
}