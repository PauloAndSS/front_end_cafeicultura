// lib/viewmodels/talhao/cadastrar_talhao_viewmodel.dart
import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';

class CadastrarTalhaoViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingVariedades = false;
  bool get isLoadingVariedades => _isLoadingVariedades;
  
  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  List<Variedade> _variedades = [];
  List<Variedade> get variedades => _variedades;
  
  final _talhaoService = ServicesTalhao();

  Future<void> carregarVariedades() async {
    _isLoadingVariedades = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _variedades = await _talhaoService.buscarVariedades();
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao carregar variedades. Tente novamente mais tarde.';
    } finally {
      _isLoadingVariedades = false;
      notifyListeners();
    }
  }


  Future<bool> cadastrarTalhao(Talhao talhao) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resultado = await _talhaoService.cadastrar(talhao);
      return resultado;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao cadastrar talhão. Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}