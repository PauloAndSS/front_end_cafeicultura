import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class PrestadorDeServico extends PapelPessoa {
  
  PrestadorDeServico({
    super.id,
    required super.pessoa,
  });

  factory PrestadorDeServico.fromJson(Map<String, dynamic> json) {
    return PrestadorDeServico(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
    );
  }
}