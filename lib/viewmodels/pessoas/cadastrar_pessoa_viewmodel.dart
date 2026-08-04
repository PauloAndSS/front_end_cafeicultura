import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';

enum TipoPapelCadastro { funcionario, meeiro, fornecedor, prestador, cliente }

class CadastroPessoaViewModel extends ChangeNotifier {
  final ServicesFuncionario _servicesFuncionario = ServicesFuncionario();
  final ServicesMeeiro _servicesMeeiro = ServicesMeeiro();
  final ServicesFornecedor _servicesFornecedor = ServicesFornecedor();
  final ServicesPrestadorDeServico _servicesPrestador =
      ServicesPrestadorDeServico();
  final ServicesCliente _servicesCliente = ServicesCliente();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  TipoPapelCadastro? _papelSelecionado;
  TipoPapelCadastro? get papelSelecionado => _papelSelecionado;

  void selecionarPapel(TipoPapelCadastro? papel) {
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
      switch (_papelSelecionado!) {
        case TipoPapelCadastro.funcionario:
          await _servicesFuncionario.cadastrar(objetoPapel as Funcionario);
          break;
        case TipoPapelCadastro.meeiro:
          await _servicesMeeiro.cadastrar(objetoPapel as Meeiro);
          break;
        case TipoPapelCadastro.fornecedor:
          await _servicesFornecedor.cadastrar(objetoPapel as Fornecedor);
          break;
        case TipoPapelCadastro.prestador:
          await _servicesPrestador.cadastrar(objetoPapel as PrestadorDeServico);
          break;
        case TipoPapelCadastro.cliente:
          await _servicesCliente.cadastrar(objetoPapel as Cliente);
          break;
      }
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
