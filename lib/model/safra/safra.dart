class Safra {
  final int? id;
  final int? propriedadeId;
  final String nome;
  final String descricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String status;
  final bool ativa;

  Safra({
    this.id,
    this.propriedadeId,
    this.nome = '',
    this.descricao = '',
    this.dataInicio,
    this.dataFim,
    String? status,
    bool? ativa,
  })  : status = status ?? (dataFim != null ? 'Encerrada' : 'Ativa'),
        ativa = ativa ?? (dataFim == null);

  factory Safra.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['safraId'] ?? json['idSafra'];
    final rawPropriedadeId =
        json['propriedadeId'] ??
        json['idPropriedade'] ??
        json['propriedade']?['id'];

    return Safra(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? ''),
      propriedadeId: rawPropriedadeId is num
          ? rawPropriedadeId.toInt()
          : int.tryParse(rawPropriedadeId?.toString() ?? ''),
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      dataInicio: _parseDate(
        json['dataInicio'] ??
            json['inicio'] ??
            json['data_inicio'] ??
            json['dataInicial'] ??
            json['data_inicial'],
      ),
      dataFim: _parseDate(
        json['dataFim'] ??
            json['fim'] ??
            json['data_fim'] ??
            json['dataTermino'] ??
            json['data_termino'] ??
            json['dataFinalizacao'] ??
            json['data_finalizacao'] ??
            json['dataEncerramento'] ??
            json['data_encerramento'],
      ),
      // status e ativa não vêm mais do backend: são derivados
      // automaticamente pelo construtor a partir de dataFim.
      // Se tem data de fim, é porque a safra já foi encerrada.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (propriedadeId != null) 'propriedadeId': propriedadeId,
      'nome': nome,
      'descricao': descricao,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'status': status,
      'ativa': ativa,
    };
  }

  bool get isEncerrada => !ativa;

  /// Nome de exibição da safra: se houver um nome cadastrado, usa ele;
  /// senão, gera automaticamente no formato "Safra 2026/2027" a partir do
  /// ano de início (o ano seguinte representa o fechamento do ciclo).
  String get nomeExibicao {
    if (nome.isNotEmpty) {
      return nome;
    }

    final anoBase = dataInicio?.year ?? dataFim?.year;
    if (anoBase != null) {
      return 'Safra $anoBase/${anoBase + 1}';
    }

    return 'Safra ${id ?? 'sem identificador'}';
  }

  /// "Safra 2026/2027" ou "Safra 2025/2026 (Encerrada)".
  ///
  /// A situação entra no próprio rótulo onde não há selo ao lado. No card de
  /// detalhes de uma atividade, por exemplo, saber que a safra fechou explica
  /// por que ela não aparece mais como opção em lançamento novo.
  String get nomeComSituacao =>
      isEncerrada ? '$nomeExibicao (Encerrada)' : nomeExibicao;

  String get periodoTexto {
    if (dataInicio == null && dataFim == null) {
      return 'Período não informado';
    }

    if (dataInicio != null && dataFim != null) {
      return '${_formatDate(dataInicio!)} até ${_formatDate(dataFim!)}';
    }

    if (dataInicio != null) {
      return 'Início em ${_formatDate(dataInicio!)}';
    }

    return 'Finalizada em ${_formatDate(dataFim!)}';
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    return null;
  }

  // Importante para o DropdownButtonFormField: sem isso, o Flutter compara
  // por identidade de objeto e, assim que a lista de safras é recarregada
  // (nova instância criada a partir do JSON), o valor selecionado deixa de
  // "bater" com os itens da lista e o select aparece vazio.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Safra && other.id != null && other.id == id;
  }

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;
}

/// Representa um evento de relatório vindo da rota de relatório da safra.
/// A API retorna cada evento como `{ "modulo": "TRATO_CULTURAL", "dados": {...} }`.
/// Hoje só existe o módulo TRATO_CULTURAL, mas a estrutura já é preparada
/// para outros módulos no futuro (ex: financeiro, colheita).
class SafraEvento {
  final int? id;
  final String modulo;
  final String tipoTrato;
  final String descricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final DateTime? dataCadastro;
  final int? idTalhao;
  final List<ResponsavelEvento> responsaveis;
  final List<InsumoUtilizado> insumosUtilizados;
  final List<TransacaoFinanceira> transacoesFinanceiras;

  const SafraEvento({
    this.id,
    this.modulo = '',
    this.tipoTrato = '',
    this.descricao = '',
    this.dataInicio,
    this.dataFim,
    this.dataCadastro,
    this.idTalhao,
    this.responsaveis = const [],
    this.insumosUtilizados = const [],
    this.transacoesFinanceiras = const [],
  });

  /// Não existe mais um atributo "confirmado" vindo da API: o evento (o
  /// trato cultural, no caso do módulo TRATO_CULTURAL) é considerado
  /// concluído quando `dataFim` está preenchida — mesma lógica usada em
  /// `Safra.isEncerrada`. Enquanto `dataFim` for nula, o evento é tratado
  /// como em andamento/pendente.
  bool get concluido => dataFim != null;

  factory SafraEvento.fromJson(Map<String, dynamic> json) {
    final modulo = json['modulo']?.toString() ?? '';
    final dadosRaw = json['dados'];
    final dados = dadosRaw is Map ? Map<String, dynamic>.from(dadosRaw) : <String, dynamic>{};

    final responsaveisRaw = dados['responsaveis'];
    final responsaveis = <ResponsavelEvento>[];
    if (responsaveisRaw is List) {
      for (final item in responsaveisRaw) {
        if (item is Map) {
          responsaveis.add(ResponsavelEvento.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final insumosRaw = dados['insumosUtilizados'];
    final insumos = <InsumoUtilizado>[];
    if (insumosRaw is List) {
      for (final item in insumosRaw) {
        if (item is Map) {
          insumos.add(InsumoUtilizado.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawIdTalhao = dados['idTalhao'];

    final transacoesRaw = dados['transacoesFinanceiras'];
    final transacoes = <TransacaoFinanceira>[];
    if (transacoesRaw is List) {
      for (final item in transacoesRaw) {
        if (item is Map) {
          transacoes.add(TransacaoFinanceira.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SafraEvento(
      id: dados['id'] is num ? (dados['id'] as num).toInt() : null,
      modulo: modulo,
      tipoTrato: dados['tipoTrato']?.toString() ?? '',
      descricao: dados['descricao']?.toString() ?? '',
      dataInicio: _parseDate(dados['dataInicio']),
      dataFim: _parseDate(dados['dataFim']),
      dataCadastro: _parseDate(dados['dataCadastro']),
      idTalhao: rawIdTalhao is num ? rawIdTalhao.toInt() : int.tryParse(rawIdTalhao?.toString() ?? ''),
      responsaveis: responsaveis,
      insumosUtilizados: insumos,
      transacoesFinanceiras: transacoes,
    );
  }

  /// Título amigável do evento: usa o tipo de trato quando disponível
  /// (ex: "Adubação"), senão cai no nome do módulo.
  String get tituloExibicao {
    if (tipoTrato.isNotEmpty) {
      return tipoTrato;
    }
    return _nomeAmigavelModulo(modulo);
  }

  static String _nomeAmigavelModulo(String modulo) {
    switch (modulo) {
      case 'TRATO_CULTURAL':
        return 'Trato cultural';
      default:
        return modulo.isEmpty ? 'Evento' : modulo;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class ResponsavelEvento {
  final int? id;
  final String razaoSocial;
  final String cnpj;

  const ResponsavelEvento({this.id, this.razaoSocial = '', this.cnpj = ''});

  factory ResponsavelEvento.fromJson(Map<String, dynamic> json) {
    return ResponsavelEvento(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      razaoSocial: json['razaoSocial']?.toString() ?? json['nome']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
    );
  }
}

class InsumoUtilizado {
  final int? id;
  final String descricao;
  final String medida;
  final num quantidade;

  const InsumoUtilizado({
    this.id,
    this.descricao = '',
    this.medida = '',
    this.quantidade = 0,
  });

  factory InsumoUtilizado.fromJson(Map<String, dynamic> json) {
    final insumoRaw = json['insumo'];
    final insumo = insumoRaw is Map ? Map<String, dynamic>.from(insumoRaw) : <String, dynamic>{};
    final qtdRaw = json['qtdUsada'];

    return InsumoUtilizado(
      id: insumo['id'] is num ? (insumo['id'] as num).toInt() : null,
      descricao: insumo['descricao']?.toString() ?? '',
      medida: insumo['medida']?.toString() ?? '',
      quantidade: qtdRaw is num ? qtdRaw : (num.tryParse(qtdRaw?.toString() ?? '') ?? 0),
    );
  }

  String get textoQuantidade {
    final qtdTexto = quantidade == quantidade.roundToDouble()
        ? quantidade.toInt().toString()
        : quantidade.toString();
    return medida.isNotEmpty ? '$qtdTexto $medida' : qtdTexto;
  }
}

/// Representa um lançamento financeiro associado a um evento da safra
/// (`dados.transacoesFinanceiras` no relatório geral).
///
/// ATENÇÃO: no exemplo de payload recebido até agora esse array veio vazio,
/// então os nomes de campo abaixo (`valor`, `tipo`, `categoria`, `data`)
/// são um "melhor palpite" baseado em convenções comuns da API — cada
/// campo tenta algumas variações plausíveis de nome. Assim que houver um
/// exemplo real com uma transação preenchida, é só confirmar/ajustar os
/// nomes usados em `fromJson` abaixo.
class TransacaoFinanceira {
  final int? id;
  final String tipo; // ex: "RECEITA" / "DESPESA" (ou "ENTRADA" / "SAIDA")
  final String categoria; // ex: "Fertilizantes", "Mão de obra", "Combustível"
  final String descricao;
  final num valor;
  final DateTime? data;

  const TransacaoFinanceira({
    this.id,
    this.tipo = '',
    this.categoria = '',
    this.descricao = '',
    this.valor = 0,
    this.data,
  });

  factory TransacaoFinanceira.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawValor = json['valor'] ?? json['montante'] ?? json['amount'] ?? json['valorTotal'];
    final rawData = json['data'] ??
        json['dataTransacao'] ??
        json['dataLancamento'] ??
        json['dataCadastro'] ??
        json['createdAt'];

    return TransacaoFinanceira(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? ''),
      tipo: (json['tipo'] ?? json['tipoTransacao'] ?? json['natureza'])?.toString() ?? '',
      categoria: (json['categoria'] ?? json['tipoGasto'] ?? json['classificacao'])?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      valor: rawValor is num ? rawValor : (num.tryParse(rawValor?.toString() ?? '') ?? 0),
      data: _parseDataTransacao(rawData),
    );
  }

  /// Considera receita quando o tipo indicar entrada de dinheiro. Qualquer
  /// outro valor (inclusive vazio/desconhecido) é tratado como despesa por
  /// segurança, para não inflar receita indevidamente em somatórios.
  bool get isReceita {
    final tipoNormalizado = tipo.toUpperCase();
    return tipoNormalizado.contains('RECEITA') || tipoNormalizado.contains('ENTRADA');
  }

  bool get isDespesa => !isReceita;

  static DateTime? _parseDataTransacao(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}