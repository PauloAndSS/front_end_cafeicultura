import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class Cliente extends PapelPessoa {
  
  Cliente({
    super.id,
    required super.pessoa,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
    );
  }
}