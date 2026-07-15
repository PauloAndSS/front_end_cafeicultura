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

  final _proprietarioService = ServicesProprietario();

  Future<Proprietario?> adicionarEndereco({
    required Proprietario proprietarioLogado,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
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
      );

      final idProprietario = proprietarioLogado.id;
      if (idProprietario == null) {
        throw Exception('Tentativa de cadastrar endereço em um usuário sem ID.');
      }

      // 2. Chama a API para salvar o Endereço
      await _proprietarioService.cadastrarEndereco(
        idProprietario: idProprietario,
        endereco: enderecoFinal,
      );

      // 3. Atualiza as entidades locais
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

    } on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.map((msg) => '• $msg').join('\n');
      return null;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return null;
    } on ArgumentError catch (e) {
      _mensagemErro = "Verifique os dados: ${e.message}";
      return null;
    } catch (e) {
      _mensagemErro = 'Erro ao salvar o endereço. Tente novamente.';
      debugPrint("Erro interno: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}