import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';

abstract class Pessoa {
  final String id;
  final Endereco? endereco;

  Pessoa({
    required this.id,
    this.endereco,
  });
}