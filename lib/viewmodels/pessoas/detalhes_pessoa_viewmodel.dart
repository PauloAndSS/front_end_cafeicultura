import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
class DetalhesPessoaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  PapelPessoa? _pessoaDetalhe;
  PapelPessoa? get pessoaDetalhe => _pessoaDetalhe;

  late final Map<TipoPapel, dynamic> _services;

  DetalhesPessoaViewModel() {
    _services = {
      TipoPapel.funcionario: ServicesFuncionario(),
      TipoPapel.meeiro: ServicesMeeiro(),
      TipoPapel.fornecedor: ServicesFornecedor(),
      TipoPapel.prestador: ServicesPrestadorDeServico(),
      TipoPapel.cliente:  ServicesCliente(),
    };
  }
  Future<void> buscarPorId(int id, TipoPapel tipoPapel) async {
    _isLoading = true;
    _mensagemErro = null;
    _pessoaDetalhe = null;
    notifyListeners();

    try {
      _pessoaDetalhe = await _services[tipoPapel]!.buscarPorId(id);
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao buscar os detalhes. Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> excluir(int id, TipoPapel tipoPapel) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _services[tipoPapel].excluir(id);
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao excluir. Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarSalario(int id, double salario) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _services[TipoPapel.funcionario].atualizarSalario(id, salario);
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao atualizar o salário. Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}