import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class IdentificacaoLogin { 
  final String tipoEntrada; 
  final String valor;

  IdentificacaoLogin._({required this.valor, required this.tipoEntrada});

  factory IdentificacaoLogin.criar(String entradaBruta) {
    final textoLimpo = entradaBruta.trim();

    if (textoLimpo.isEmpty) {
      throw ArgumentError('O login não pode estar vazio.');
    }

    if (textoLimpo.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(textoLimpo)) {
      Email.criar(textoLimpo);
      return IdentificacaoLogin._(valor: textoLimpo, tipoEntrada: "email");
    }

    final apenasNumeros = textoLimpo.replaceAll(RegExp(r'[^0-9]'), '');

    if (apenasNumeros.length <= 11) {
      CPF.criar(textoLimpo);
      return IdentificacaoLogin._(valor: apenasNumeros, tipoEntrada: "cpf"); 
    } else {
      CNPJ.criar(textoLimpo);
      return IdentificacaoLogin._(valor: apenasNumeros, tipoEntrada: "cnpj"); 
    }
  }
}

class Credencial {
  final IdentificacaoLogin identificacao; 
  final String valorEntrada;
  final String tipoEntrada;
  final String senha;

  Credencial({
    required this.identificacao,
    required this.senha,
  }) : valorEntrada = identificacao.valor, 
       tipoEntrada = identificacao.tipoEntrada {
    if (senha.trim().isEmpty) {
      throw ArgumentError('A senha é obrigatória.');
    }
  }
}