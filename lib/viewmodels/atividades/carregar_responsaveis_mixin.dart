import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Listagem paginada de quem pode ser responsável por uma atividade agrícola.
///
/// Toda atividade (trato cultural, colheita, despolpa...) escolhe responsáveis
/// da mesma forma, e o modal `mostrarSelecaoResponsaveis` consome exatamente
/// esta interface — por isso a paginação vive aqui e não dentro de um ViewModel
/// específico.
mixin CarregarResponsaveisMixin on DescarteSeguroMixin {
  static const int _limiteResponsaveisPorPagina = 20;

  static const int _maxPaginas = 50;

  final _pessoaService = ServicesPessoa();

  final List<PapelPessoa> _responsaveis = [];
  List<PapelPessoa> get responsaveis => List.unmodifiable(_responsaveis);

  bool _responsaveisCarregados = false;
  bool get responsaveisCarregados => _responsaveisCarregados;

  bool _isCarregandoResponsaveis = false;
  bool get isCarregandoResponsaveis => _isCarregandoResponsaveis;

  bool _isCarregandoMaisResponsaveis = false;
  bool get isCarregandoMaisResponsaveis => _isCarregandoMaisResponsaveis;

  String? _mensagemErroResponsaveis;
  String? get mensagemErroResponsaveis => _mensagemErroResponsaveis;

  int _paginaResponsaveis = 1;
  int _totalPaginasResponsaveis = 1;

  bool get temMaisResponsaveis =>
      _paginaResponsaveis < _totalPaginasResponsaveis;

  Future<void> carregarResponsaveis() async {
    if (_isCarregandoResponsaveis) return;

    _isCarregandoResponsaveis = true;
    _mensagemErroResponsaveis = null;
    _responsaveis.clear();
    _paginaResponsaveis = 1;
    _totalPaginasResponsaveis = 1;
    notificarComSeguranca();

    try {
      final resultado = await _pessoaService.buscarPorProprietario(
        pagina: _paginaResponsaveis,
        limite: _limiteResponsaveisPorPagina,
      );

      _responsaveis.addAll(_apenasElegiveis(resultado.data));
      _totalPaginasResponsaveis = resultado.totalPaginas;
      _responsaveisCarregados = true;
    } on ApiException catch (e) {
      _mensagemErroResponsaveis = e.mensagem;
    } catch (e) {
      _mensagemErroResponsaveis =
          'Ocorreu um erro interno ao carregar os responsáveis. Tente novamente mais tarde.';
    } finally {
      _isCarregandoResponsaveis = false;
      notificarComSeguranca();
    }
  }

  Future<void> carregarMaisResponsaveis() async {
    if (_isCarregandoResponsaveis ||
        _isCarregandoMaisResponsaveis ||
        !temMaisResponsaveis ||
        _paginaResponsaveis >= _maxPaginas) {
      return;
    }

    _isCarregandoMaisResponsaveis = true;
    notificarComSeguranca();

    final proximaPagina = _paginaResponsaveis + 1;

    try {
      final resultado = await _pessoaService.buscarPorProprietario(
        pagina: proximaPagina,
        limite: _limiteResponsaveisPorPagina,
      );

      _paginaResponsaveis = proximaPagina;
      _totalPaginasResponsaveis = resultado.totalPaginas;
      _responsaveis.addAll(_apenasElegiveis(resultado.data));
    } on ApiException catch (e) {
      _mensagemErroResponsaveis = e.mensagem;
    } catch (e) {
      _mensagemErroResponsaveis =
          'Ocorreu um erro interno ao carregar mais responsáveis. Tente novamente mais tarde.';
    } finally {
      _isCarregandoMaisResponsaveis = false;
      notificarComSeguranca();
    }
  }

  /// Cliente e fornecedor não executam atividade — só entram na lista quem
  /// pode ser apontado como responsável.
  List<PapelPessoa> _apenasElegiveis(List<PapelPessoa> pagina) {
    return pagina
        .where((papel) =>
            papel is Funcionario ||
            papel is Meeiro ||
            papel is PrestadorDeServico)
        .where((papel) => papel.id != null)
        .toList();
  }
}
