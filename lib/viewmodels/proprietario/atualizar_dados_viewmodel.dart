import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';

class AtualizarDadosViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  final _proprietarioService = ServicesProprietario();

  Future<Proprietario?> carregarDadosProprietario(int idProprietario) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      
      final proprietario = await _proprietarioService.buscarPorId(idProprietario);
     
      return proprietario;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;
    } catch (e) {
      _mensagemErro = 'Erro de conexão. Tente novamente.';
      debugPrint('Erro ao carregar dados: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}