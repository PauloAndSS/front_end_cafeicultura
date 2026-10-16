import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

class Diarista extends PapelPessoa {
  final double? valorHora;

  Diarista({
    super.id,
    required super.pessoa,
    this.valorHora,
  });

  factory Diarista.fromJson(Map<String, dynamic> json) {
    return Diarista(
      id: json['id'],
      pessoa: PessoaFactory.fromJson(json),
      valorHora: json['valorHora'] != null
          ? double.tryParse(json['valorHora'].toString())
          : null,
    );
  }

  String get valorHoraParaExibicao =>
      valorHora == null ? 'Não informado' : formatarMoeda(valorHora!);

  String get valorHoraParaEdicao =>
      valorHora == null ? '' : formatarDecimalDuasCasas(valorHora!);

  @override
  Diarista comId(int id) =>
      Diarista(id: id, pessoa: pessoa, valorHora: valorHora);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (valorHora != null) 'valorHora': valorHora,
    };
  }
}
