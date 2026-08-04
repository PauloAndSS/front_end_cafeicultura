import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';

class PessoasViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  List<PapelPessoa> _todasPessoas = [];

  final ServicesPessoa _service;

  PessoasViewModel({ServicesPessoa? service}) 
      : _service = service ?? ServicesPessoa();

  List<Funcionario> get funcionarios => _todasPessoas.whereType<Funcionario>().toList();
  List<Meeiro> get meeiros => _todasPessoas.whereType<Meeiro>().toList();
  List<Cliente> get clientes => _todasPessoas.whereType<Cliente>().toList();
  List<Fornecedor> get fornecedores => _todasPessoas.whereType<Fornecedor>().toList();
  List<PrestadorDeServico> get prestadores => _todasPessoas.whereType<PrestadorDeServico>().toList();

  Future<void> carregarPessoas() async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();
    try {
      _todasPessoas = await _service.buscarPorProprietario();
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno no aplicativo. Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}