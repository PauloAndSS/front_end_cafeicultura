import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

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

  String get salarioParaExibicao =>
      salario == null ? 'Não informado' : formatarMoeda(salario!);

  String get salarioParaEdicao =>
      salario == null ? '' : formatarDecimalDuasCasas(salario!);

  @override
  Funcionario comId(int id) =>
      Funcionario(id: id, pessoa: pessoa, ctps: ctps, salario: salario);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      
      if (ctps != null) 'ctps': ctps,
      if (salario != null) 'salario': salario,
    };
  }
}