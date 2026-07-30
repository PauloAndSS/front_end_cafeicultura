import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';

class Variedade {
  final int id;
  final String descricao;
  final String especie;

  Variedade({
    required this.id,
    required this.descricao,
    required this.especie
  });

  factory Variedade.fromJson(dynamic json) {
    if (json is String) {
      return Variedade(id: 0, descricao: json, especie: json);
    }
    if (json is Map<String, dynamic>) {
      return Variedade(
        id: json['id'] ?? 0,
        descricao: json['descricao'] ?? '',
        especie: json['especie'] ?? '',
      );
    }
    return Variedade(id: 0, descricao: json.toString(),especie: json.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'especie': especie
    };
  }

  @override
  String toString() => descricao;
}
class Talhao {
  final int? id;
  final String nome;
  final int idPropriedade;
  final int qtdPeCafe;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final Tamanho tamanho;
  final String especie;
  final List<int>? variedadesIds;
  final List<Variedade>? variedadesCafe;
  final bool? arquivado;
  

  Talhao({
    this.id,
    required this.nome,
    required this.idPropriedade,
    required this.qtdPeCafe,
    required this.dataInicio,
    this.dataFim,
    required this.tamanho,
    required this.especie,
    this.variedadesIds,
    this.variedadesCafe,
    this.arquivado,
  });
  
  factory Talhao.fromJson(Map<String, dynamic> json) {
    return Talhao(
      id: json['id'],
      nome: json['nome'] ?? '',
      idPropriedade: json['idPropriedade'] ?? 0,
      qtdPeCafe: json['qtdPeCafe'] ?? 0,
      dataInicio: json['dataInicio'] != null 
          ? DateTime.parse(json['dataInicio']) 
          : DateTime.now(),
      dataFim: json['dataFim'] != null 
          ? DateTime.parse(json['dataFim']) 
          : null,
      tamanho: json['tamanho'] != null 
          ? Tamanho.fromJson(json['tamanho']) 
          : Tamanho(valor: 0.0, medida: Medida.hectare),
      especie: json['especie'] ?? '',
      variedadesIds: json['variedadesIds'] != null 
          ? List<int>.from(json['variedadesIds']) 
          : null,
      variedadesCafe: json['variedadesCafe'] != null 
          ? (json['variedadesCafe'] as List).map((v) => Variedade.fromJson(v)).toList() 
          : null,
      arquivado: json['arquivado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'idPropriedade': idPropriedade,
      'qtdPeCafe': qtdPeCafe,
      'dataInicio': dataInicio.toUtc().toIso8601String(),
      if (dataFim != null) 'dataFim': dataFim!.toUtc().toIso8601String(),
      'tamanho': tamanho.toJson(),
      'especie': especie,
      if (variedadesIds != null) 'variedadesIds': variedadesIds,
      if (variedadesCafe != null) 'variedadesCafe': variedadesCafe!.map((v) => v.toJson()).toList(),
      if (arquivado != null) 'arquivado': arquivado,
    };
  }
}