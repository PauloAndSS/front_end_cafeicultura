import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class Email {
  final String endereco;

  Email._(this.endereco);

  factory Email.criar(String valor) {
    if (!isValid(valor)) {
      throw ArgumentError('E-mail inválido');
    }

    final emailNormalizado = valor.trim().toLowerCase();
    
    return Email._(emailNormalizado);
  }

  static bool isValid(String valor) {
    final emailLimpo = valor.trim();
    if (emailLimpo.isEmpty) return false;

    final regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    
    return regex.hasMatch(emailLimpo);
  }
}

class Telefone {
  final String numero;

  Telefone._(this.numero);

  factory Telefone.criar(String valor) {
    if (!isValid(valor)) {
      throw ArgumentError('Telefone inválido');
    }
    final numerosLimpos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    return Telefone._(numerosLimpos);
  }

  static bool isValid(String valor) {
    final numerosLimpos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numerosLimpos.length < 10 || numerosLimpos.length > 11) {
      return false;
    }

    //O DDD não pode ser menor que 11
    final ddd = int.tryParse(numerosLimpos.substring(0, 2));
    if (ddd == null || ddd < 11) {
      return false;
    }

    if (numerosLimpos.length == 11 && numerosLimpos[2] != '9') {
      return false;
    }

    return true;
  }

  String get formatado {
    final ddd = numero.substring(0, 2);
    
    if (numero.length == 11) {
      final primeiraParte = numero.substring(2, 7);
      final segundaParte = numero.substring(7, 11);
      return '($ddd) $primeiraParte-$segundaParte';
    } else {
      final primeiraParte = numero.substring(2, 6);
      final segundaParte = numero.substring(6, 10);
      return '($ddd) $primeiraParte-$segundaParte';
    }
  }
}
abstract class Usuario {
  final int id;
  final Email email;
  final Telefone telefone;
  final Pessoa pessoa;
  Usuario({
    required this.email,
    required this.telefone,
    required this.pessoa,
    required this.id,
  });

  String get identificadorPrincipal {
    if (pessoa is PessoaFisica) {
      return (pessoa as PessoaFisica).cpf.formatado;
    } else if (pessoa is PessoaJuridica) {
      return (pessoa as PessoaJuridica).cnpj.formatado;
    }
    return email.endereco;
  }
}
