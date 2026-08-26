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

  static String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (value.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres';
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

  static String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'O nome deve conter pelo menos 3 caracteres';
    }

    return null;
  }

  static String? validarRazaoSocial(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A Razão Social é obrigatória';
    }
    if (value.trim().length < 3) {
      return 'Razão Social muito curta';
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
