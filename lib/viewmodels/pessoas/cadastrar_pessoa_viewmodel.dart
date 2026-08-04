import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class CadastroPessoaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  TipoPapel? _papelSelecionado;
  TipoPapel? get papelSelecionado => _papelSelecionado;

  late final Map<TipoPapel, dynamic> _services;

  CadastroPessoaViewModel() {
    _services = {
      TipoPapel.funcionario: ServicesFuncionario(),
      TipoPapel.meeiro: ServicesMeeiro(),
      TipoPapel.fornecedor: ServicesFornecedor(),
      TipoPapel.prestador: ServicesPrestadorDeServico(),
      TipoPapel.cliente:  ServicesCliente(),
    };
  }

  void selecionarPapel(TipoPapel? papel) {
    _papelSelecionado = papel;
    notifyListeners();
  }

  Future<bool> cadastrarPessoa({required dynamic objetoPapel}) async {
    if (_papelSelecionado == null) {
      _mensagemErro = 'Selecione o papel da pessoa.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _services[_papelSelecionado!].cadastrar(objetoPapel);
      
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno no aplicativo. Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}