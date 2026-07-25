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
      _mensagemErro = 'Erro ao carregar variedades.';
      print('Erro: $e');
    } finally {
      _isLoadingVariedades = false;
      notifyListeners();
    }
  }

  Future<bool?> cadastrarTalhao(Talhao talhao) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resultado = await _talhaoService.cadastrar(talhao);
      return resultado;
    } on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.join('\n');
      return null;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;
    } catch (e) {
      _mensagemErro = 'Erro interno ao cadastrar talhão. Verifique os dados.';
      print('Erro: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}