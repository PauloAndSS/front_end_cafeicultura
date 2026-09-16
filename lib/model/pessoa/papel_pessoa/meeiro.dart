import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class Meeiro extends PapelPessoa {
  
  Meeiro({
    super.id,
    required super.pessoa,
  });

  factory Meeiro.fromJson(Map<String, dynamic> json) {
    return Meeiro(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
    );
  }
}