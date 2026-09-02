import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

abstract class Pessoa {
  final int? id;
  final Endereco? endereco;

  Pessoa({
    this.id,
    this.endereco,
  });

  Map<String, dynamic> toJson();
  String get nomeParaExibicao;
  String get documentoFormatado;
}

extension ResumoDeResponsaveis on Iterable<Pessoa> {
  String get contagem => contarItens(length, 'responsável', 'responsáveis');
}
