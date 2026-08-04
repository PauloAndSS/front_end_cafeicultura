import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class CadastrarEnderecoViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  final _proprietarioService = ServicesProprietario();


  Future<Proprietario?> adicionarEndereco({
    required Proprietario proprietarioLogado,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
    String? pais,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final cep = CEP.criar(cepDigitado); 
      final enderecoFinal = Endereco(
        cidade: cidade.trim(),
        bairro: bairro.trim(),
        cep: cep,
        logradouro: logradouro.trim(),
        uf: uf,
        pais: pais,
      );

      final idProprietario = proprietarioLogado.id;
      if (idProprietario == null) {
        throw Exception('Tentativa de cadastrar endereço em um usuário sem ID.');
      }

      await _proprietarioService.cadastrarEndereco(
        idProprietario: idProprietario,
        endereco: enderecoFinal,
      );

      final pessoaAnterior = proprietarioLogado.pessoa;
      final pessoaCompleta = pessoaAnterior is PessoaFisica
          ? PessoaFisica(
              id: pessoaAnterior.id,
              nome: pessoaAnterior.nome,
              cpf: pessoaAnterior.cpf,
              endereco: enderecoFinal,
            )
          : PessoaJuridica(
              id: pessoaAnterior.id,
              razaoSocial: (pessoaAnterior as PessoaJuridica).razaoSocial,
              cnpj: pessoaAnterior.cnpj,
              inscricaoEstadual: pessoaAnterior.inscricaoEstadual,
              endereco: enderecoFinal,
            );

      return Proprietario(
        id: idProprietario,
        email: proprietarioLogado.email,
        telefone: proprietarioLogado.telefone,
        pessoa: pessoaCompleta,
      );

    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno no aplicativo. Tente novamente mais tarde.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}