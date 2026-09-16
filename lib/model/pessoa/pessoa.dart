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

  String get iniciais {
    final palavras = nomeParaExibicao
        .split(RegExp(r'\s+'))
        .where((palavra) => palavra.isNotEmpty)
        .toList();

    if (palavras.isEmpty) return '?';

    if (palavras.length == 1) {
      return palavras.first.substring(0, 1).toUpperCase();
    }

    final primeira = palavras.first.substring(0, 1);
    final ultima = palavras.last.substring(0, 1);

    return '$primeira$ultima'.toUpperCase();
  }
}

extension ResumoDeResponsaveis on Iterable<Pessoa> {
  String get contagem => contarItens(length, 'responsável', 'responsáveis');
}
