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

/// Cotação do dia da CCCV (arábica dura, arábica rio e conilon).
class CotacaoDiaCccv {
  final int? dia;
  final double arabicaDura;
  final double arabicaRio;
  final double conilon;

  const CotacaoDiaCccv({
    this.dia,
    required this.arabicaDura,
    required this.arabicaRio,
    required this.conilon,
  });

  factory CotacaoDiaCccv.fromJson(Map<String, dynamic> json) {
    return CotacaoDiaCccv(
      dia: (json['dia'] as num?)?.toInt(),
      arabicaDura: (json['arabica_dura'] as num?)?.toDouble() ?? 0,
      arabicaRio: (json['arabica_rio'] as num?)?.toDouble() ?? 0,
      conilon: (json['conilon'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Média mensal da CCCV (arábica dura, arábica rio e conilon).
class MediaMensalCccv {
  final double arabicaDura;
  final double arabicaRio;
  final double conilon;

  const MediaMensalCccv({
    required this.arabicaDura,
    required this.arabicaRio,
    required this.conilon,
  });

  factory MediaMensalCccv.fromJson(Map<String, dynamic> json) {
    return MediaMensalCccv(
      arabicaDura: (json['arabica_dura'] as num?)?.toDouble() ?? 0,
      arabicaRio: (json['arabica_rio'] as num?)?.toDouble() ?? 0,
      conilon: (json['conilon'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CccvCotacao {
  final String fonte;
  final CotacaoDiaCccv cotacaoDia;
  final MediaMensalCccv mediaMensal;

  const CccvCotacao({
    required this.fonte,
    required this.cotacaoDia,
    required this.mediaMensal,
  });

  factory CccvCotacao.fromJson(Map<String, dynamic> json) {
    return CccvCotacao(
      fonte: (json['fonte'] as String?) ?? 'cccv',
      cotacaoDia: CotacaoDiaCccv.fromJson(
        (json['cotacao_dia'] as Map<String, dynamic>?) ?? const {},
      ),
      mediaMensal: MediaMensalCccv.fromJson(
        (json['media_mensal'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class RespostaCotacaoCafe {
  final DateTime? dataColeta;
  final List<ItemCooabriel>? cooabriel;
  final List<ItemCotacaoCafe> painelDoCafe;
  final CccvCotacao? cccv;
  final List<String> erros;

  const RespostaCotacaoCafe({
    this.dataColeta,
    this.cooabriel,
    this.painelDoCafe = const [],
    this.cccv,
    this.erros = const [],
  });

  bool get temDadosDoPainel => painelDoCafe.isNotEmpty;
  bool get temDadosDaCooabriel => cooabriel != null && cooabriel!.isNotEmpty;
  bool get temDadosDaCccv => cccv != null;
  bool get temAlgumDado =>
      temDadosDoPainel || temDadosDaCooabriel || temDadosDaCccv;

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

    CccvCotacao? parseCccv(dynamic bruto) {
      if (bruto == null || bruto is! Map<String, dynamic>) return null;
      return CccvCotacao.fromJson(bruto);
    }

    return RespostaCotacaoCafe(
      dataColeta: json['data_coleta'] != null
          ? DateTime.tryParse(json['data_coleta'].toString())
          : null,
      cooabriel: parseListaCooabriel(json['cooabriel']),
      painelDoCafe: parseListaPainel(json['painel_do_cafe']),
      cccv: parseCccv(json['cccv']),
      erros: (json['erros'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
    );
  }
}