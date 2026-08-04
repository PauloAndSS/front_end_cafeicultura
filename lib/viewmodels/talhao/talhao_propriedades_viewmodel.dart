// lib/viewmodels/talhao/talhoes_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class TalhoesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingMais = false;
  String? _mensagemErro;
  List<Talhao> _todosTalhoes = [];

  int _paginaAtual = 1;
  bool _temMaisPaginas = true;
  int? _idPropriedadeAtual;

  bool get isLoading => _isLoading;
  bool get isLoadingMais => _isLoadingMais;
  String? get mensagemErro => _mensagemErro;
  bool get temMaisPaginas => _temMaisPaginas;

  List<Talhao> get talhoes => _todosTalhoes;

  List<Talhao> get talhoesAtivos =>
      _todosTalhoes.where((t) => t.dataFim == null).toList();

  List<Talhao> get talhoesEncerrados =>
      _todosTalhoes.where((t) => t.dataFim != null).toList();

  final _service = ServicesTalhao();

  Future<void> carregarTalhoes(int idPropriedade) async {
    _idPropriedadeAtual = idPropriedade;
    _paginaAtual = 1;
    _temMaisPaginas = true;
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final novosTalhoes = await _service.buscarTodosTalhoesPorPropriedade(
        idPropriedade,
        pagina: _paginaAtual,
        limite: 10,
      );

      _todosTalhoes = novosTalhoes;

      if (novosTalhoes.length < 10) {
        _temMaisPaginas = false;
      }
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro de conexão ao carregar talhões.';
      debugPrint('Erro no carregamento dos talhões: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca a próxima página e anexa ao final da lista existente
  Future<void> carregarMaisTalhoes() async {
    if (_isLoadingMais || !_temMaisPaginas || _idPropriedadeAtual == null) return;

    _isLoadingMais = true;
    notifyListeners();

    try {
      final proximaPagina = _paginaAtual + 1;
      final novosTalhoes = await _service.buscarTodosTalhoesPorPropriedade(
        _idPropriedadeAtual!,
        pagina: proximaPagina,
        limite: 10,
      );

      if (novosTalhoes.isEmpty) {
        _temMaisPaginas = false;
      } else {
        _paginaAtual = proximaPagina;
        _todosTalhoes.addAll(novosTalhoes);

        if (novosTalhoes.length < 10) {
          _temMaisPaginas = false;
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar mais talhões: $e');
    } finally {
      _isLoadingMais = false;
      notifyListeners();
    }
  }

  void limparDados() {
    _todosTalhoes = [];
    _mensagemErro = null;
    _paginaAtual = 1;
    _temMaisPaginas = true;
    _idPropriedadeAtual = null;
    notifyListeners();
  }

  void escutarIsLoggedIn(SessionViewModel session) {
    session.addListener(() {
      if (!session.isLoggedIn) {
        limparDados();
      }
    });
  }
}