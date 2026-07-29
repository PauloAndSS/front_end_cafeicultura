import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class Fornecedor extends PapelPessoa {
  
  Fornecedor({
    super.id,
    required super.pessoa,
  });

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
    );
  }
}