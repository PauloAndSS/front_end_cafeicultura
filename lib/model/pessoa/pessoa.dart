import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';

abstract class Pessoa {
  final int? id;
  final Endereco? endereco;

  Pessoa({
    this.id,
    this.endereco,
  });

  Map<String, dynamic> toJson();
  
}