import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';

class EnderecoDTO {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final String cep;
  final String pais;

  EnderecoDTO({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.cep,
    required this.pais,
  });

  factory EnderecoDTO.fromEntity(Endereco endereco) {
    return EnderecoDTO(
      logradouro: endereco.logradouro,
      bairro: endereco.bairro,
      cidade: endereco.cidade,
      uf: endereco.uf.name,
      cep: endereco.cep.formatado, 
      pais: endereco.pais,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'cep': cep,
      'pais': pais,
    };
  }
}