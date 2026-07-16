import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class Proprietario extends Usuario {
  Proprietario({
    super.id,
    required super.email,
    required super.telefone,
    required super.pessoa,
  });
  factory Proprietario.fromJson(Map<String, dynamic> json) {
    Endereco? enderecoObj;
    if (json['endereco'] != null) {
      enderecoObj = Endereco.fromJson(json['endereco']);
    }

    Pessoa pessoaObj;
    String? tipoPessoa = json['tipoPessoa']?.toString().toLowerCase();
    if (tipoPessoa == null || tipoPessoa == 'null') {
      if (json['cpf'] != null && json['cpf'].toString().trim().isNotEmpty) {
        tipoPessoa = 'fisica';
      } else if (json['cnpj'] != null && json['cnpj'].toString().trim().isNotEmpty) {
        tipoPessoa = 'juridica';
      }
    }
    if (tipoPessoa == 'fisica') {
      pessoaObj = PessoaFisica(
        id: json['id'],
        nome: json['nome'],
        cpf: CPF.criar(json['cpf']),
        endereco: enderecoObj,
      );
    } else if (tipoPessoa == 'juridica') {
      pessoaObj = PessoaJuridica(
        id: json['id'],
        razaoSocial: json['razaoSocial'],
        cnpj: CNPJ.criar(json['cnpj']),
        inscricaoEstadual: json['inscrEstadual'],
        endereco: enderecoObj,
      );
    } else {
      throw ArgumentError('Tipo de pessoa inválido ou não informado: $tipoPessoa');
    }

    return Proprietario(
      id: json['id'],
      email: Email.criar(json['email']),
      telefone: Telefone.criar(json['telefone']),
      pessoa: pessoaObj,
    );
  }
}