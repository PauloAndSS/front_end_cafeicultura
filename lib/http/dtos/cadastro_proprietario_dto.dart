import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

class IdentificadorPessoa {
  static String? identificar(Pessoa pessoa) {
    if (pessoa is PessoaFisica) {
      return "fisica";
    } else if (pessoa is PessoaJuridica) {
      return "juridica";
    }
    return null;
  }
}

class CadastroProprietarioDTO {
  final Proprietario proprietario;
  final String senha;
   
  CadastroProprietarioDTO({required this.proprietario, required this.senha});

  Map<String, dynamic> cadastrarSemEnderecoToJson() {
    final pessoa = proprietario.pessoa;
    final tipoPessoa = IdentificadorPessoa.identificar(pessoa);
    
    final isFisica = pessoa is PessoaFisica;

    return {
      "tipoPessoa": tipoPessoa,
      
      "nome": isFisica ? pessoa.nome : null,
      
      "cpf": isFisica ? pessoa.cpf.numero : null,
      
      "razaoSocial": !isFisica ? (pessoa as PessoaJuridica).razaoSocial : null,
      "cnpj": !isFisica ? (pessoa as PessoaJuridica).cnpj.numero : null,
      "inscrEstadual": !isFisica ? (pessoa as PessoaJuridica).inscricaoEstadual : null,
      
      "email": proprietario.email.endereco,
      "telefone": proprietario.telefone.numero,
      "senha": senha,
    };
  }
}