import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';

class AtualizarPropriedadeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _mensagemErro;
  Propriedade? _propriedade;

  bool get isLoading => _isLoading;
  String? get mensagemErro => _mensagemErro;
  Propriedade? get propriedade => _propriedade;

  final _service = ServicesPropriedade();

  Future<void> carregarPropriedade(int id) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _propriedade = await _service.buscarPorId(id);
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro ao carregar os dados da propriedade.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarPropriedadeCompleta({
    required int id,
    required String nome,
    required Tamanho tamanho,
    required Endereco endereco,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await Future.wait([
        _service.atualizarNome(id, nome),
        _service.atualizarTamanho(id, tamanho),
        _service.atualizarEndereco(id, endereco),
      ]);
      
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Falha ao atualizar a propriedade.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}