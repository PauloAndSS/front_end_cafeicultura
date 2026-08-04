import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

enum TipoPessoa { fisica, juridica }

class CadastrarUsuarioViewModel extends ChangeNotifier {
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  TipoPessoa _tipoPessoaAtual = TipoPessoa.fisica;
  TipoPessoa get tipoPessoaAtual => _tipoPessoaAtual;

  final _proprietarioService = ServicesProprietario();
  void alterarTipoPessoa(TipoPessoa novoTipo) {
    if (_tipoPessoaAtual != novoTipo) {
      _tipoPessoaAtual = novoTipo;
      notifyListeners();
    }
  }

  Future<Proprietario?> cadastrarDadosBasicos({
    required String email,
    required String senha,
    required String telefone,
    required SessionViewModel session,
    String? nome,
    String? cpf,
    String? razaoSocial,
    String? cnpj,
    String? inscEstadual,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
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

      final proprietarioSemId = Proprietario(
        email: emailVo,
        telefone: telefoneVo,
        pessoa: pessoaCadastrada,
      );

      await _proprietarioService.cadastrar(
        proprietario: proprietarioSemId,
        senha: senha,
      );
      
      final identificacao = IdentificacaoLogin.criar(proprietarioSemId.email.endereco);
      
      final authService = ServicesAuth();
      final authResponse = await authService.autenticar(
        LoginRequestDTO(
          tipoEntrada: identificacao.tipoEntrada,
          entrada: identificacao.valor,
          senha: senha,
        ),
      );

      final idGerado = authResponse.sessaoAtiva?.idUsuario;
      if (idGerado == null) {
        throw Exception('Erro ao capturar ID do usuário no sistema.');
      }

      String nomeParaLogar = pessoaCadastrada is PessoaFisica ? pessoaCadastrada.nome : (pessoaCadastrada as PessoaJuridica).razaoSocial;
          
      await session.login(idGerado, nomeParaLogar);

      return Proprietario(
        id: idGerado,
        email: proprietarioSemId.email,
        telefone: proprietarioSemId.telefone,
        pessoa: pessoaCadastrada,
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