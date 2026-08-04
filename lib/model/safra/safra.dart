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

class SafraEvento {
  final int? id;
  final String descricao;
  final String tipo;
  final String data;
  final String status;
  final String responsavel;
  final String valor;
  final String quantidade;
  final String observacao;

  const SafraEvento({
    this.id,
    this.descricao = '',
    this.tipo = '',
    this.data = '',
    this.status = '',
    this.responsavel = '',
    this.valor = '',
    this.quantidade = '',
    this.observacao = '',
  });

  factory SafraEvento.fromJson(Map<String, dynamic> json) {
    return SafraEvento(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      descricao: _readString(json['descricao']) ?? _readString(json['nome']) ?? _readString(json['titulo']) ?? '',
      tipo: _readString(json['tipo']) ?? _readString(json['categoria']) ?? '',
      data: _readString(json['data']) ?? _readString(json['dataEvento']) ?? _readString(json['createdAt']) ?? '',
      status: _readString(json['status']) ?? _readString(json['situacao']) ?? '',
      responsavel: _readString(json['responsavel']) ?? _readString(json['responsavelNome']) ?? _readString(json['usuario']) ?? '',
      valor: _readString(json['valor']) ?? _readString(json['valorTotal']) ?? _readString(json['valorFinanceiro']) ?? '',
      quantidade: _readString(json['quantidade']) ?? _readString(json['qtd']) ?? _readString(json['quantidadeUtilizada']) ?? '',
      observacao: _readString(json['observacao']) ?? _readString(json['detalhes']) ?? _readString(json['observacoes']) ?? '',
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}