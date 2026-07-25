import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';

class DetalhesTalhaoViewModel extends ChangeNotifier {
  final _talhaoService = ServicesTalhao();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  Future<bool?> encerrar(int idTalhao, DateTime dataFim) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resultado = await _talhaoService.encerrarTalhao(idTalhao, dataFim);
      return resultado;
    } on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.join('\n');
      return null;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;
    } catch (e) {
      _mensagemErro = 'Erro interno ao encerrar talhão.';
      print('Erro: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}