import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

abstract class PapelPessoa {
  final int? id;
  final Pessoa pessoa;

  PapelPessoa({
    this.id,
    required this.pessoa,
  });

  PapelPessoa comId(int id);

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      ...pessoa.toJson(),
    };
  }
}