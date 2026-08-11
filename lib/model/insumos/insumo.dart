enum MedidaInsumo {
  unidade('un', 'Unidade (un)'),
  quilograma('kg', 'Quilograma (kg)'),
  grama('g', 'Grama (g)'),
  miligrama('mg', 'Miligrama (mg)'),
  litro('l', 'Litro (l)'),
  mililitro('ml', 'Mililitro (ml)'),
  metroCubico('m3', 'Metro cúbico (m³)');

  const MedidaInsumo(this.sigla, this.rotulo);

  final String sigla;

  final String rotulo;
  static MedidaInsumo? deSigla(String? sigla) {
    if (sigla == null) return null;

    final normalizada = sigla.trim().toLowerCase();

    for (final medida in MedidaInsumo.values) {
      if (medida.sigla == normalizada) return medida;
    }

    return null;
  }
}

class Insumo {

  final int? id;
  final String descricao;
  final MedidaInsumo medida;

  Insumo({this.id, required this.descricao, required this.medida});

  Map<String, dynamic> toJson(int idProprietario) {
    return {
      'idProprietario': idProprietario,
      'descricao': descricao,
      'medida': medida.sigla,
    };
  }

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'],
      descricao: json['descricao'] ?? 'Sem descrição',
      medida: MedidaInsumo.deSigla(json['medida']) ?? MedidaInsumo.unidade,
    );
  }

  @override
  String toString() => descricao;
}
