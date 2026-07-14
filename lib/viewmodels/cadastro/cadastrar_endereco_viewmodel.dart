import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/auth_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_auth.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/credencial.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class CadastrarEnderecoViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  bool _erroDaPagAnterior = false;
  bool get erroDaPagAnterior => _erroDaPagAnterior;

  final ServicesProprietario _proprietarioService;

  CadastrarEnderecoViewmodel({required ServicesProprietario service})
    : _proprietarioService = service;

  void _verificarOrigemDoErro() {
    if (_mensagemErro == null) {
      _erroDaPagAnterior = false;
      return;
    }

    final termosPaginaAnterior = [
      'cpf',
      'email',
      'e-mail',
      'telefone',
      'senha',
      'fisica',
      'cnpj',
      'nome',
    ];

    final erroMinusculo = _mensagemErro!.toLowerCase();

    // .any() retorna true se pelo menos um item da lista satisfizer a condição
    _erroDaPagAnterior = termosPaginaAnterior.any(
      (termo) => erroMinusculo.contains(termo),
    );
  }

  Future<Proprietario?> finalizarCadastroComEndereco({
    required Proprietario proprietarioSemEndereco,
    required String senha,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
    required SessionViewModel session,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    _erroDaPagAnterior = false; // Importante resetar aqui também!
    notifyListeners();

    try {
      final cep = CEP.criar(cepDigitado); // Pode lançar ArgumentError

      final enderecoFinal = Endereco(
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
              endereco: enderecoFinal,
            )
          : PessoaJuridica(
              id: pessoaAnterior.id,
              razaoSocial: (pessoaAnterior as PessoaJuridica).razaoSocial,
              cnpj: pessoaAnterior.cnpj,
              inscricaoEstadual: pessoaAnterior.inscricaoEstadual,
              endereco: enderecoFinal,
            );

      Proprietario proprietario = Proprietario(
        id: proprietarioSemEndereco.id,
        email: proprietarioSemEndereco.email,
        telefone: proprietarioSemEndereco.telefone,
        pessoa: pessoaCompleta,
      );

      await _proprietarioService.cadastrar(
        proprietario: proprietario,
        senha: senha,
      );

      final identificacao = IdentificacaoLogin.criar(
        proprietario.email.endereco,
      );
      final authService = ServicesAuth();

      final authResponse = await authService.autenticar(
        LoginRequestDTO(
          tipoEntrada: identificacao.tipoEntrada,
          entrada: identificacao.valor,
          senha: senha,
        ),
      );
      print('🔍 DEBUG ID LOGIN: ${authResponse.sessaoAtiva?.idUsuario}');
      final idGerado = authResponse.sessaoAtiva?.idUsuario;
      if (idGerado == null) {
        throw Exception('API não retornou o ID gerado para o proprietário.');
      } else {
        print('ID GERADO: $idGerado');
      }

      String nomeParaLogar = 'Produtor';
      if (pessoaCompleta is PessoaFisica) {
        nomeParaLogar = pessoaCompleta.nome;
      } else if (pessoaCompleta is PessoaJuridica) {
        nomeParaLogar = pessoaCompleta.razaoSocial;
      }
      await session.login(idGerado, nomeParaLogar);

      await _proprietarioService.cadastrarEndereco(
        idProprietario: idGerado,
        endereco: enderecoFinal,
      );

      return Proprietario(
        id: idGerado,
        email: proprietario.email,
        telefone: proprietario.telefone,
        pessoa: pessoaCompleta,
      );
    } on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.map((msg) => '• $msg').join('\n');
      _verificarOrigemDoErro();
      return null;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      _verificarOrigemDoErro();
      return null;
    } on ArgumentError catch (e) {
      _mensagemErro = "Verifique os dados: ${e.message}";
      debugPrint("Erro de argumento: $e");
      return null;
    } catch (e) {
      debugPrint("Erro interno: $e");
      _mensagemErro =
          'Erro ao finalizar o cadastro. Tente novamente mais tarde.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Proprietario?> finalizarCadastroSemEndereco({
    required Proprietario proprietario,
    required String senha,
    required SessionViewModel session,
  }) async {
    _isLoading = true;
    notifyListeners();
    _mensagemErro = null;
    _erroDaPagAnterior = false;

    try {
      await _proprietarioService.cadastrar(
        proprietario: proprietario,
        senha: senha,
      );

      final identificacao = IdentificacaoLogin.criar(
        proprietario.email.endereco,
      );
      final authService = ServicesAuth();

      final authResponse = await authService.autenticar(
        LoginRequestDTO(
          tipoEntrada: identificacao.tipoEntrada,
          entrada: identificacao.valor,
          senha: senha,
        ),
      );

      final idGerado = authResponse.sessaoAtiva?.idUsuario;
      print('🔍 DEBUG ID LOGIN: ${authResponse.sessaoAtiva?.idUsuario}');

      if (idGerado == null) {
        throw Exception('API não retornou o ID gerado para o proprietário.');
      } else {
        print('ID GERADO: $idGerado');
      }

      String nomeParaLogar = 'Produtor';
      final pessoa = proprietario.pessoa;
      if (pessoa is PessoaFisica) {
        nomeParaLogar = pessoa.nome;
      } else if (pessoa is PessoaJuridica) {
        nomeParaLogar = pessoa.razaoSocial;
      }
      await session.login(idGerado, nomeParaLogar);

      return Proprietario(
        id: idGerado,
        email: proprietario.email,
        telefone: proprietario.telefone,
        pessoa: proprietario.pessoa,
      );
    } on ApiValidationException catch (e) {
      _mensagemErro = e.mensagens.map((msg) => '• $msg').join('\n');
      _verificarOrigemDoErro();
      return null;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      _verificarOrigemDoErro();
      return null;
    } catch (e) {
      _mensagemErro =
          "Erro ao finalizar o cadastro. Verifique sua conexão e tente novamente.";
      debugPrint("Erro interno: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
