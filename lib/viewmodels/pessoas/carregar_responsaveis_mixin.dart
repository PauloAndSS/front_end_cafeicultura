import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

mixin CarregarResponsaveisMixin on NotificaSeVivoMixin {
  static const int _limiteResponsaveisPorPagina = 20;

  static const int _maxPaginas = 50;

  final _pessoaService = ServicesPessoa();

  late final EstadoDeCarga _cargaResponsaveis = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  late final EstadoDeCarga _cargaMaisResponsaveis = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: _cargaResponsaveis,
  );

  final List<PapelPessoa> _pessoas = [];

  List<PapelPessoa> get pessoas => List.unmodifiable(_pessoas);

  List<PapelPessoa> get responsaveis =>
      List.unmodifiable(_pessoas.where(_podeSerResponsavel));

  List<PapelPessoa> get fornecedores =>
      List.unmodifiable(_pessoas.whereType<Fornecedor>());

  bool _responsaveisCarregados = false;
  bool get responsaveisCarregados => _responsaveisCarregados;

  bool get isCarregandoResponsaveis => _cargaResponsaveis.isLoading;

  bool get isCarregandoMaisResponsaveis => _cargaMaisResponsaveis.isLoading;

  String? get mensagemErroResponsaveis => _cargaResponsaveis.mensagemErro;

  int _paginaResponsaveis = 1;
  int _totalPaginasResponsaveis = 1;

  bool get temMaisResponsaveis =>
      _paginaResponsaveis < _totalPaginasResponsaveis;

  Future<void> carregarResponsaveis() {
    if (_cargaResponsaveis.isLoading) return Future.value();

    _pessoas.clear();
    _paginaResponsaveis = 1;
    _totalPaginasResponsaveis = 1;

    return _cargaResponsaveis.executar(
      chamada: () async {
        final resultado = await _pessoaService.buscarPorProprietario(
          pagina: _paginaResponsaveis,
          limite: _limiteResponsaveisPorPagina,
        );

        _pessoas.addAll(_comIdentificacao(resultado.data));
        _totalPaginasResponsaveis = resultado.totalPaginas;
        _responsaveisCarregados = true;
      },
      aoFalhar: () {},
    );
  }

  Future<List<Pessoa>> carregarPessoas() async {
    await _garantirPaginaCarregada();

    return _pessoas.map((papel) => papel.pessoa).toList();
  }

  Future<List<Pessoa>> carregarFornecedores() async {
    await _garantirPaginaCarregada();

    return fornecedores.map((papel) => papel.pessoa).toList();
  }

  Future<void> _garantirPaginaCarregada() async {
    if (!_responsaveisCarregados) await carregarResponsaveis();
  }

  Future<void> carregarMaisResponsaveis() {
    if (_cargaResponsaveis.isLoading ||
        _cargaMaisResponsaveis.isLoading ||
        !temMaisResponsaveis ||
        _paginaResponsaveis >= _maxPaginas) {
      return Future.value();
    }

    final proximaPagina = _paginaResponsaveis + 1;

    return _cargaMaisResponsaveis.executar(
      chamada: () async {
        final resultado = await _pessoaService.buscarPorProprietario(
          pagina: proximaPagina,
          limite: _limiteResponsaveisPorPagina,
        );

        _paginaResponsaveis = proximaPagina;
        _totalPaginasResponsaveis = resultado.totalPaginas;
        _pessoas.addAll(_comIdentificacao(resultado.data));
      },
      aoFalhar: () {},
    );
  }

  List<PapelPessoa> _comIdentificacao(List<PapelPessoa> pagina) {
    return pagina.where((papel) => papel.id != null).toList();
  }

  static bool _podeSerResponsavel(PapelPessoa papel) =>
      papel is Funcionario || papel is Meeiro || papel is PrestadorDeServico;
}
