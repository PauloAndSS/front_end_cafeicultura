import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/diarista.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

enum TipoPapel { funcionario, diarista, meeiro, fornecedor, prestador, cliente }
class PessoaFactory {
  PessoaFactory._(); 

  static Pessoa fromJson(Map<String, dynamic> json) {
    final tipo = json['tipoPessoa']?.toString().toLowerCase();

    if (tipo == 'juridica') return PessoaJuridica.fromJson(json);
    if (tipo == 'fisica') return PessoaFisica.fromJson(json);

    if (_preenchido(json['cnpj']) || _preenchido(json['razaoSocial'])) {
      return PessoaJuridica.fromJson(json);
    }

    return PessoaFisica.fromJson(json);
  }

  static bool _preenchido(Object? valor) =>
      valor != null && valor.toString().trim().isNotEmpty;

  static TipoPapel obterTipoPapel(PapelPessoa papel) {
    if (papel is Funcionario) return TipoPapel.funcionario;
    if (papel is Diarista) return TipoPapel.diarista;
    if (papel is Fornecedor) return TipoPapel.fornecedor;
    if (papel is Cliente) return TipoPapel.cliente;
    if (papel is Meeiro) return TipoPapel.meeiro;
    if (papel is PrestadorDeServico) return TipoPapel.prestador;
    
    return TipoPapel.cliente;
  }
}
extension RotulosDoPapel on TipoPapel {
  String get rotulo => switch (this) {
        TipoPapel.funcionario => 'funcionário',
        TipoPapel.diarista => 'diarista',
        TipoPapel.meeiro => 'meeiro',
        TipoPapel.fornecedor => 'fornecedor',
        TipoPapel.prestador => 'prestador de serviço',
        TipoPapel.cliente => 'cliente',
      };

  String get rotuloPlural => switch (this) {
        TipoPapel.funcionario => 'funcionários',
        TipoPapel.diarista => 'diaristas',
        TipoPapel.meeiro => 'meeiros',
        TipoPapel.fornecedor => 'fornecedores',
        TipoPapel.prestador => 'prestadores de serviço',
        TipoPapel.cliente => 'clientes',
      };

  String get titulo => switch (this) {
        TipoPapel.prestador => 'Prestador de Serviço',
        _ => capitalizar(rotulo),
      };

  String get tituloPlural => switch (this) {
        TipoPapel.prestador => 'Prestadores de Serviço',
        _ => capitalizar(rotuloPlural),
      };

  bool get aceitaPessoaJuridica =>
      this != TipoPapel.funcionario &&
      this != TipoPapel.diarista &&
      this != TipoPapel.meeiro;
}
