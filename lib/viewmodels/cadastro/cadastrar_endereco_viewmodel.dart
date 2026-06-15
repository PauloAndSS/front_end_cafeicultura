import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class CadastrarEnderecoViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  final ServicesProprietario _service;

  CadastrarEnderecoViewmodel({required ServicesProprietario service}) : _service = service; 

  Future<Proprietario?> finalizarCadastroComEndereco({
    required Proprietario proprietarioSemEndereco,
    required String senha,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
  }) async {
    _isLoading = true;
    notifyListeners();
    _mensagemErro = null;

    try{
      final cep = CEP.criar(cepDigitado);
      
      final enderecoFinal = Endereco(
        id: 0,
        cidade: cidade.trim(),
        bairro: bairro.trim(),
        cep: cep,
        logradouro: logradouro.trim(),
        uf: uf,
      );

      final pessoaAnterior = proprietarioSemEndereco.pessoa;
      final pessoaCompleta = pessoaAnterior is PessoaFisica
        ? PessoaFisica(
            id: pessoaAnterior.id,
            nome: pessoaAnterior.nome,
            cpf: pessoaAnterior.cpf,
            endereco: enderecoFinal, // Adicionando o endereço
          )
        : PessoaJuridica(
            id: pessoaAnterior.id,
            razaoSocial: (pessoaAnterior as PessoaJuridica).razaoSocial,
            cnpj: pessoaAnterior.cnpj,
            inscricaoEstadual: pessoaAnterior.inscricaoEstadual,
            endereco: enderecoFinal, // Adicionando o endereço
          );
      
      Proprietario proprietario = Proprietario(
        id: proprietarioSemEndereco.id,
        email: proprietarioSemEndereco.email,
        telefone: proprietarioSemEndereco.telefone,
        pessoa: pessoaCompleta,
      );
      
      await _service.cadastrarSemEndereco(proprietario: proprietario, senha: senha);
      return proprietario;
    }on ArgumentError catch(e){
      _mensagemErro = "Verifique os dados: ${e.message}";
      debugPrint("Erro interno: $e");
      return null;
    }catch(e){
    debugPrint("Erro interno: $e");
    _mensagemErro = 'Erro ao finalizar o cadastro. Tente novamente mais tarde.';
    return null;
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Proprietario?> finalizarCadastroSemEndereco({
    required Proprietario proprietario,
    required String senha,
  }) async {
    _isLoading = true;
    notifyListeners();
    _mensagemErro = null;

    try{
      final dtoProprietario = await _service.cadastrarSemEndereco(proprietario: proprietario, senha: senha);
      return Proprietario(
        id: dtoProprietario.id,
        email: proprietario.email,
        telefone: proprietario.telefone,
        pessoa: proprietario.pessoa,
      );
    }on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.map((msg) => '• $msg').join('\n');
      return null;

    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;

    } catch (e) {
      _mensagemErro = "Erro ao finalizar o cadastro. Verifique sua conexão e tente novamente.";
      debugPrint("Erro interno: $e"); 
      return null;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
