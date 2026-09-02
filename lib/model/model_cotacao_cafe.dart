class ItemCotacaoCafe {
  final String nome;
  final double valor;

  const ItemCotacaoCafe({required this.nome, required this.valor});

  factory ItemCotacaoCafe.fromJson(Map<String, dynamic> json) {
    return ItemCotacaoCafe(
      nome: (json['name'] as String?) ?? '—',
      valor: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ItemCooabriel {
  final String tipo;
  final String data;
  final String hora;
  final String preco;

  const ItemCooabriel({
    required this.tipo,
    required this.data,
    required this.hora,
    required this.preco,
  });

  factory ItemCooabriel.fromJson(Map<String, dynamic> json) {
    return ItemCooabriel(
      tipo: (json['Tipo'] as String?) ?? '—',
      data: (json['Data'] as String?) ?? '',
      hora: (json['Hora'] as String?) ?? '',
      preco: (json['Preço'] as String?) ?? '—',
    );
  }
}

class RespostaCotacaoCafe {
  final DateTime? dataColeta;
  final List<ItemCooabriel>? cooabriel;
  final List<ItemCotacaoCafe> painelDoCafe;
  final List<String> erros;
  const RespostaCotacaoCafe({
    this.dataColeta,
    this.cooabriel,
    this.painelDoCafe = const [],
    this.erros = const [],
  });

  bool get temDadosDoPainel => painelDoCafe.isNotEmpty;
  bool get temDadosDaCooabriel => cooabriel != null && cooabriel!.isNotEmpty;
  bool get temAlgumDado => temDadosDoPainel || temDadosDaCooabriel;

  factory RespostaCotacaoCafe.fromJson(Map<String, dynamic> json) {
    List<ItemCotacaoCafe> parseListaPainel(dynamic bruto) {
      if (bruto == null || bruto is! List) return const [];
      return bruto
          .whereType<Map<String, dynamic>>()
          .map(ItemCotacaoCafe.fromJson)
          .toList();
    }

    List<ItemCooabriel>? parseListaCooabriel(dynamic bruto) {
      if (bruto == null || bruto is! List) return null;
      return bruto
          .whereType<Map<String, dynamic>>()
          .map(ItemCooabriel.fromJson)
          .toList();
    }

    return RespostaCotacaoCafe(
      dataColeta: json['data_coleta'] != null
          ? DateTime.tryParse(json['data_coleta'].toString())
          : null,
      cooabriel: parseListaCooabriel(json['cooabriel']),
      painelDoCafe: parseListaPainel(json['painel_do_cafe']),
      erros: (json['erros'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
    );
  }
}