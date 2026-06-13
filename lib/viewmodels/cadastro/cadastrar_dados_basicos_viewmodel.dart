import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

enum TipoPessoa { fisica, juridica }

class CadastrarViewModel extends ChangeNotifier {
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  TipoPessoa _tipoPessoaAtual = TipoPessoa.fisica;
  TipoPessoa get tipoPessoaAtual => _tipoPessoaAtual;

  void alterarTipoPessoa(TipoPessoa novoTipo) {
    if (_tipoPessoaAtual != novoTipo) {
      _tipoPessoaAtual = novoTipo;
      notifyListeners();
    }
  }

  ({Proprietario proprietario, String senha})? cadastroDadosBasicos({
    required String email,
    required String senha,
    required String telefone,
    String? nome,
    String? cpf,
    String? razaoSocial,
    String? cnpj,
    String? inscEstadual,
  }) {
    _isLoading = true;
    notifyListeners();

    try {
      final emailVo = Email.criar(email);
      final telefoneVo = Telefone.criar(telefone);

      Pessoa pessoaCadastrada;

      if (_tipoPessoaAtual == TipoPessoa.fisica) {
        
        if (nome == null || cpf == null) throw ArgumentError('Dados de PF incompletos');
        
        final cpfVo = CPF.criar(cpf);
        
        pessoaCadastrada = PessoaFisica(
          nome: nome.trim(),
          cpf: cpfVo,
        );
      } else {
        if (razaoSocial == null || cnpj == null) throw ArgumentError('Dados de PJ incompletos');
        
        final cnpjVo = CNPJ.criar(cnpj);
        
        pessoaCadastrada = PessoaJuridica(
          razaoSocial: razaoSocial.trim(),
          cnpj: cnpjVo,
          inscricaoEstadual: inscEstadual,
        );
      }

      final proprietario = Proprietario(
        email: emailVo,
        telefone: telefoneVo,
        pessoa: pessoaCadastrada,
      );
      
      return (proprietario: proprietario, senha: senha);
    } on ArgumentError catch (e) {
      debugPrint('Erro de validação no Domínio: ${e.message}');
      return null;
    } catch (e) {
      _mensagemErro = 'Erro ao cadastrar. Tente novamente mais tarde.';
      debugPrint('Erro interno: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}