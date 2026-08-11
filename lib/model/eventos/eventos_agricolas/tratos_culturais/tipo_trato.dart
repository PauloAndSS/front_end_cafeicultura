class TipoTrato {
  final int? id;
  final String descricao;

  TipoTrato({
    required this.id,
    required this.descricao,
  });

  TipoTrato.apenasDescricao(this.descricao) : id = null;

  factory TipoTrato.fromJson(Map<String, dynamic> json) {
    return TipoTrato(
      id: json['id'],
      descricao: json['descricao'] ?? '',
    );
  }

//métodos para dropdowns
  @override
  bool operator ==(Object other) =>
      other is TipoTrato && other.id == id && other.descricao == descricao;

  @override
  int get hashCode => Object.hash(id, descricao);
}
