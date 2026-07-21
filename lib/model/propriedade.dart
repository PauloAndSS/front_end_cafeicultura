import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';

class Propriedade {
  final int? id;
  final String nome;
  final Tamanho tamanho;
  final Endereco endereco;

  Propriedade({
    this.id,
    required this.nome,
    required this.tamanho,
    required this.endereco,
  });

  factory Propriedade.fromJson(Map<String, dynamic> json) {
    return Propriedade(
      id: json['id'],
      nome: json['nome'] ?? '',
      tamanho: Tamanho.fromJson(json['tamanho']),
      endereco: Endereco.fromJson(json['endereco']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tamanho': tamanho.toJson(),
      'endereco': endereco.toJson(),
    };
  }}