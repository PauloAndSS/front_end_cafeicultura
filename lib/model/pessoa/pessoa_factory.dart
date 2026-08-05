import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

enum TipoPapel { funcionario, meeiro, fornecedor, prestador, cliente }
class PessoaFactory {
  PessoaFactory._(); 

  static Pessoa fromJson(Map<String, dynamic> json) {
    final tipo = json['tipoPessoa']?.toString().toLowerCase();

    if (tipo == 'juridica' || (json['cnpj'] != null && json['cnpj'].toString().isNotEmpty)) {
      return PessoaJuridica.fromJson(json);
    }
    
    return PessoaFisica.fromJson(json);
  }

  static TipoPapel obterTipoPapel(PapelPessoa papel) {
    if (papel is Funcionario) return TipoPapel.funcionario;
    if (papel is Fornecedor) return TipoPapel.fornecedor;
    if (papel is Cliente) return TipoPapel.cliente;
    if (papel is Meeiro) return TipoPapel.meeiro;
    if (papel is PrestadorDeServico) return TipoPapel.prestador;
    
    return TipoPapel.cliente;
  }
}