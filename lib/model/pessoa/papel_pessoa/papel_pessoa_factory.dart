import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';

class PapelPessoaFactory {
  static PapelPessoa fromJson(Map<String, dynamic> json) {
    final String papel = json['papel'] ?? ''; 

    switch (papel.toUpperCase()) {
      case 'MEEIRO':
        return Meeiro.fromJson(json);
      case 'FUNCIONARIO':
        return Funcionario.fromJson(json);
      case 'FORNECEDOR':
        return Fornecedor.fromJson(json);
      case 'CLIENTE':
        return Cliente.fromJson(json);
      case 'PRESTADORDESERVICO': 
        return PrestadorDeServico.fromJson(json);
      default:
        throw ArgumentError('Papel desconhecido ou não retornado pela API: $papel');
    }
  }
}