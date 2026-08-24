import 'package:frond_end_cafeicultura_mobile/model/periodo.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

class Safra {
  final int? id;
  final int? propriedadeId;
  final String nome;
  final String descricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  Safra({
    this.id,
    this.propriedadeId,
    this.nome = '',
    this.descricao = '',
    this.dataInicio,
    this.dataFim,
  });

  factory Safra.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawPropriedadeId = json['propriedadeId'] ?? json['propriedade']?['id'];

    return Safra(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? ''),
      propriedadeId: rawPropriedadeId is num
          ? rawPropriedadeId.toInt()
          : int.tryParse(rawPropriedadeId?.toString() ?? ''),
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      dataInicio: lerDataDoJson(json['dataInicio']),
      dataFim: lerDataDoJson(json['dataFim']),
    );
  }

  bool get encerrada => dataFim != null;

  /// Vida da safra como intervalo, ou `null` quando ela não tem `dataInicio`.
  ///
  /// Safra sem data de início não delimita nada: aceitá-la como "aberta desde
  /// sempre" liberaria o calendário de lançamento até o ano 2000 por causa de um
  /// cadastro incompleto. Quem depende do período simplesmente a descarta.
  Periodo? get periodo =>
      dataInicio == null ? null : Periodo(inicio: dataInicio!, fim: dataFim);

  String get nomeExibicao {
    if (nome.isNotEmpty) {
      return nome;
    }

    final anoBase = dataInicio?.year ?? dataFim?.year;
    final mesBase = dataInicio?.month ?? dataFim?.month;

    if (mesBase != null && anoBase != null) {
      final mesFormatado = mesBase.toString().padLeft(2, '0');
      return 'Safra $mesFormatado/$anoBase - ${anoBase + 1}';
    }

    return 'Safra ${id ?? 'sem identificador'}';
  }

  String get nomeComSituacao =>
      encerrada ? '$nomeExibicao (Encerrada)' : nomeExibicao;

  String get periodoTexto {
    if (dataInicio == null && dataFim == null) {
      return 'Período não informado';
    }

    if (dataInicio != null && dataFim != null) {
      return '${formatarDataBr(dataInicio!)} até ${formatarDataBr(dataFim!)}';
    }

    if (dataInicio != null) {
      return 'Início em ${formatarDataBr(dataInicio!)}';
    }

    return 'Finalizada em ${formatarDataBr(dataFim!)}';
  }
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
