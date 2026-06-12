import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class Validator {
  
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
      return 'Telefone inválido (digite com o DDD)';
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
    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
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
}