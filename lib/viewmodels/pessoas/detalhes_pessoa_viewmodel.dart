import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/cadastrar_pessoa_viewmodel.dart';

class DetalhesPessoaViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  PapelPessoa? _pessoaDetalhe;
  PapelPessoa? get pessoaDetalhe => _pessoaDetalhe;

  final ServicesFuncionario _serviceFuncionario;
  final ServicesMeeiro _serviceMeeiro;
  final ServicesCliente _serviceCliente;
  final ServicesFornecedor _serviceFornecedor;
  final ServicesPrestadorDeServico _servicePrestador;

  DetalhesPessoaViewModel({
    ServicesFuncionario? serviceFuncionario,
    ServicesMeeiro? serviceMeeiro,
    ServicesCliente? serviceCliente,
    ServicesFornecedor? serviceFornecedor,
    ServicesPrestadorDeServico? servicePrestador,
  })  : _serviceFuncionario = serviceFuncionario ?? ServicesFuncionario(),
        _serviceMeeiro = serviceMeeiro ?? ServicesMeeiro(),
        _serviceCliente = serviceCliente ?? ServicesCliente(),
        _serviceFornecedor = serviceFornecedor ?? ServicesFornecedor(),
        _servicePrestador = servicePrestador ?? ServicesPrestadorDeServico();

  Future<void> buscarPorId(int id, TipoPapelCadastro tipoPapel) async {
    _isLoading = true;
    _mensagemErro = null;
    _pessoaDetalhe = null;
    notifyListeners();

    try {
      switch (tipoPapel) {
        case TipoPapelCadastro.funcionario:
          _pessoaDetalhe = await _serviceFuncionario.buscarPorId(id);
          break;
        case TipoPapelCadastro.meeiro:
          _pessoaDetalhe = await _serviceMeeiro.buscarPorId(id);
          break;
        case TipoPapelCadastro.cliente:
          _pessoaDetalhe = await _serviceCliente.buscarPorId(id);
          break;
        case TipoPapelCadastro.fornecedor:
          _pessoaDetalhe = await _serviceFornecedor.buscarPorId(id);
          break;
        case TipoPapelCadastro.prestador:
          _pessoaDetalhe = await _servicePrestador.buscarPorId(id);
          break;
      }
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno ao buscar os detalhes. Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}