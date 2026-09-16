import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';

class Funcionario extends PapelPessoa {
  final String? ctps;
  final double? salario;

  Funcionario({
    super.id,
    required super.pessoa,
    this.ctps,
    this.salario,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
      ctps: json['ctps'],
      salario: json['salario'] != null ? double.tryParse(json['salario'].toString()) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      
      if (ctps != null) 'ctps': ctps,
      if (salario != null) 'salario': salario,
    };
  }
}