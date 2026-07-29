import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class PessoaFactory {
  /// Construtor privado para impedir a instanciação da Factory
  PessoaFactory._(); 

  static Pessoa fromJson(Map<String, dynamic> json) {
    final tipo = json['tipoPessoa']?.toString().toLowerCase();

    if (tipo == 'juridica' || (json['cnpj'] != null && json['cnpj'].toString().isNotEmpty)) {
      return PessoaJuridica.fromJson(json);
    }
    
    return PessoaFisica.fromJson(json);
  }
}