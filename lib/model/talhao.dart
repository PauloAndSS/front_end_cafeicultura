import 'package:frond_end_cafeicultura_mobile/model/periodo.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

class Variedade {
  final int id;
  final String descricao;
  final String especie;

  Variedade({
    required this.id,
    required this.descricao,
    required this.especie,
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
    return Variedade(
      id: 0,
      descricao: json.toString(),
      especie: json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'especie': especie,
    };
  }

  @override
  String toString() => descricao;
}

/// Data de calendário vinda do JSON, já sem hora.
///
/// A data de talhão chega como `DateTime` UTC com hora — medida em 27/08/2026,
/// a rota devolve meia-noite UTC; registros antigos chegam em meio-dia (veja
/// [dataParaJson]). Guardar o valor cru levava essa hora para dentro da tela: o
/// `showDatePicker` de encerramento usa [Talhao.dataInicio] como `firstDate` e o
/// agora local como `lastDate`, e num talhão iniciado hoje o `firstDate` caía às
/// 09:00 — antes desse horário o picker estourava a própria assertion e
/// derrubava a tela. `apenasData` lê os campos UTC crus, então meia-noite UTC
/// não vira o dia anterior.
DateTime? _dataDeCalendario(dynamic valor) {
  final data = lerDataDoJson(valor);

  return data == null ? null : apenasData(data);
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
  });

  /// Vida do talhão como intervalo: `dataFim` nulo é talhão ainda aberto.
  ///
  /// É o que permite perguntar "este talhão estava em pé naquele dia?" sem
  /// espalhar comparação de data pelas telas.
  Periodo get periodo => Periodo(inicio: dataInicio, fim: dataFim);

  /// Único critério de encerramento do talhão.
  ///
  /// O backend também devolve um `arquivado`, que o app ignora: dois marcadores
  /// para o mesmo estado divergiam na prática — um talhão arquivado sem
  /// `dataFim` caía na lista de ativos e ainda assim era desenhado como
  /// encerrado no card.
  bool get encerrado => dataFim != null;

  String get qtdPeCafeFormatada => formatarInteiro(qtdPeCafe);

  String get tamanhoFormatado => tamanho.formatado;

  String get especieFormatada =>
      especie.isEmpty ? 'Não informada' : capitalizar(especie);

  String get dataInicioFormatada {
    return formatarDataBr(dataInicio);
  }

  String? get dataFimFormatada {
    if (dataFim == null) return null;
    return formatarDataBr(dataFim!);
  }

  String get variedadesTexto {
    if (variedadesCafe == null || variedadesCafe!.isEmpty) {
      return 'Nenhuma variedade';
    }
    return variedadesCafe!.map((v) => v.descricao).join(', ');
  }

String get nomeExibicao {
    if (nome.isEmpty) return 'Talhão sem nome';
    
    final dataFormatada = formatarAnoMes(dataInicio);
    return '$nome $dataFormatada';
  }
  
  factory Talhao.fromJson(Map<String, dynamic> json) {
    return Talhao(
      id: json['id'],
      nome: json['nome'] ?? '',
      idPropriedade: json['idPropriedade'] ?? 0,
      qtdPeCafe: json['qtdPeCafe'] ?? 0,
      dataInicio: _dataDeCalendario(json['dataInicio']) ?? hoje(),
      dataFim: _dataDeCalendario(json['dataFim']),
      tamanho: json['tamanho'] != null
          ? Tamanho.fromJson(json['tamanho'])
          : Tamanho(valor: 0.0, medida: Medida.hectare),
      especie: json['especie'] ?? '',
      variedadesIds: json['variedadesIds'] != null
          ? List<int>.from(json['variedadesIds'])
          : null,
      variedadesCafe: json['variedadesCafe'] != null
          ? (json['variedadesCafe'] as List)
              .map((v) => Variedade.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final agora = DateTime.now();

    return {
      if (id != null) 'id': id,
      'nome': nome,
      'idPropriedade': idPropriedade,
      'qtdPeCafe': qtdPeCafe,
      'dataInicio': diaNaoFuturoParaJson(dataInicio, agora: agora),
      if (dataFim != null)
        'dataFim': diaNaoFuturoParaJson(dataFim!, agora: agora),
      'tamanho': tamanho.toJson(),
      'especie': especie,
      if (variedadesIds != null) 'variedadesIds': variedadesIds,
      if (variedadesCafe != null)
        'variedadesCafe': variedadesCafe!.map((v) => v.toJson()).toList(),
    };
  }
}