import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/transacao_financeira.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';

class Validator {
  static String? obrigatorio(String? value, [String? mensagem]) {
    if (value == null || value.trim().isEmpty) {
      return mensagem ?? 'Obrigatório';
    }
    return null;
  }

    static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O e-mail é obrigatório';
    }
    if (!Email.isValid(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  static String? validarTelefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O telefone é obrigatório';
    }
    if (!Telefone.isValid(value)) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? validarCPF(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O CPF é obrigatório';
    }
    if (!CPF.isValid(value)) {
      return 'CPF inválido';
    }
    return null;
  }

  static String? validarCNPJ(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O CNPJ é obrigatório';
    }
    if (!CNPJ.isValid(value)) {
      return 'CNPJ inválido';
    }
    return null;
  }


  static String? validarInscEstadual(String? value) {
    // opcional
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 8) {
      return 'Inscrição Estadual inválida.';
    }
    return null;
  }

  static String? validarCEP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O CEP é obrigatório';
    }
    final numerosLimpos = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numerosLimpos.length != 8) {
      return 'CEP inválido (deve conter 8 dígitos)';
    }
    return null;
  }

  static final RegExp _regexSenhaForte =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$');

  static final RegExp _regexEmoji = RegExp(
    r'[\u{1F1E6}-\u{1F1FF}\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
    unicode: true,
  );

  static String? validarSenhaLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    return null;
  }

  static String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (value.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres';
    }
    if (_regexEmoji.hasMatch(value)) {
      return 'A senha não pode conter emojis';
    }
    if (!_regexSenhaForte.hasMatch(value)) {
      return 'A senha deve conter letra maiúscula, minúscula, número e símbolo (!@#\$%^&*(),.?":{}|<>)';
    }
    return null;
  }

  static String? validarConfirmacaoSenha(String? senhaConfirmada, String? senhaOriginal) {
    if (senhaConfirmada == null || senhaConfirmada.isEmpty) {
      return 'Confirme sua senha';
    }
    if (senhaConfirmada != senhaOriginal) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static final RegExp _regexNome = RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]+$");

  static String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome é obrigatório';
    }
    final nome = value.trim();
    if (nome.length < 3) {
      return 'O nome deve conter pelo menos 3 caracteres';
    }
    if (nome.length > 100) {
      return 'O nome deve ter no máximo 100 caracteres';
    }

    return null;
  }

  static String? validarNomePessoaFisica(String? value) {
    final erroDeTamanho = validarNome(value);
    if (erroDeTamanho != null) {
      return erroDeTamanho;
    }
    if (!_regexNome.hasMatch(value!.trim())) {
      return 'O nome deve conter apenas letras';
    }

    return null;
  }

  static String? validarRazaoSocial(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A Razão Social é obrigatória';
    }
    final razaoSocial = value.trim();
    if (razaoSocial.length < 3) {
      return 'Razão Social muito curta';
    }
    if (razaoSocial.length > 100) {
      return 'Razão Social deve ter no máximo 100 caracteres';
    }
    return null;
  }

  static String? valorPositivo(String? value, [String? mensagem]) {
    if (value == null || value.trim().isEmpty) {
      return mensagem ?? 'Obrigatório';
    }

    final numero = AppMasks.paraDouble(value);

    if (numero == null) {
      return 'Valor inválido';
    }
    if (numero <= 0) {
      return 'Informe um valor maior que zero';
    }
    return null;
  }

  static const int minimoCaracteresDescricao = 3;

  static String? descricaoDeTransacao(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Obrigatório';
    }
    if (texto.length < minimoCaracteresDescricao) {
      return 'Descreva com pelo menos $minimoCaracteresDescricao caracteres';
    }
    return null;
  }

  static String? selecaoObrigatoria(Object? valor) =>
      valor == null ? 'Obrigatório' : null;

  static String? beneficiadoObrigatorio(Object? beneficiado) =>
      beneficiado == null ? 'Obrigatório' : null;

  static String? validarFormaPagamento(
    FormaPagamento? forma,
    TipoOperacao? tipoOperacao,
  ) {
    if (forma == null) {
      return 'Obrigatório';
    }
    if (tipoOperacao == null) {
      return 'Selecione o tipo de operação antes';
    }
    if (!TransacaoFinanceira.combinacaoValida(forma, tipoOperacao)) {
      return TransacaoFinanceira.mensagemCombinacaoInvalida;
    }
    return null;
  }
}
