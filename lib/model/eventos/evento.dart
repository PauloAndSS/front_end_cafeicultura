import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';

export 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';

abstract class Evento {
  final int? id;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final String? descricao;
  final DateTime? dataCadastro;

  final int? idSafra;
  final List<Pessoa> responsaveis;

  Evento({
    this.id,
    required this.dataInicio,
    this.dataFim,
    this.descricao,
    this.dataCadastro,
    this.idSafra,
    this.responsaveis = const [],
  });

  Evento.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dataInicio = _lerData(json['dataInicio']) ?? DateTime.now(),
        dataFim = _lerData(json['dataFim']),
        descricao = json['descricao'],
        dataCadastro = _lerData(json['dataCadastro']),
        idSafra = _lerIdSafra(json),
        responsaveis = _lerResponsaveis(json);

  String get tituloExibicao;

  /// Situação no tempo: sem data de término o evento pode estar apenas
  /// agendado, e é a data de início contra hoje que separa os dois casos.
  StatusEvento get status {
    if (dataFim != null) return StatusEvento.finalizado;

    return ehFutura(dataInicio)
        ? StatusEvento.agendado
        : StatusEvento.emAndamento;
  }

  bool get agendado => status == StatusEvento.agendado;

  /// Já começou e ainda não terminou — **não** é sinônimo de "não finalizado".
  /// Quem quer dizer "ainda editável" deve usar `!finalizado`.
  bool get emAndamento => status == StatusEvento.emAndamento;

  bool get finalizado => status == StatusEvento.finalizado;

  String get statusFormatado => status.rotulo;

  String get dataInicioFormatada => formatarDataBr(dataInicio);

  String? get dataFimFormatada =>
      dataFim == null ? null : formatarDataBr(dataFim!);

  String? get dataCadastroFormatada =>
      dataCadastro == null ? null : formatarDataBr(dataCadastro!);

  String get descricaoTexto {
    final texto = descricao?.trim() ?? '';
    return texto.isEmpty ? 'Sem descrição' : texto;
  }

  String get responsaveisTexto => responsaveis.isEmpty
      ? 'Nenhum responsável'
      : responsaveis.map((pessoa) => pessoa.nomeParaExibicao).join(', ');

  Map<String, dynamic> toJson() {
    final descricaoLimpa = descricao?.trim() ?? '';

    return {
      'dataInicio': dataInicio.toUtc().toIso8601String(),
      if (dataFim != null) 'dataFim': dataFim!.toUtc().toIso8601String(),
      if (descricaoLimpa.isNotEmpty) 'descricao': descricaoLimpa,
      if (idSafra != null) 'idSafra': idSafra,
      'responsaveisIds': responsaveis
          .map((pessoa) => pessoa.id)
          .whereType<int>()
          .toList(),
    };
  }

  static DateTime? _lerData(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  static int? _lerIdSafra(Map<String, dynamic> json) {
    return json['safra'] is Map<String, dynamic> ? json['safra']['id'] : null;
  }

  static List<Pessoa> _lerResponsaveis(Map<String, dynamic> json) {
    final lista = json['responsaveis'];

    if (lista is! List) return const [];

    return lista
        .whereType<Map<String, dynamic>>()
        .map(_tentarLerPessoa)
        .whereType<Pessoa>()
        .toList();
  }

  static Pessoa? _tentarLerPessoa(Map<String, dynamic> json) {
    try {
      final pessoa = PessoaFactory.fromJson(json);
      return pessoa.id == null ? null : pessoa;
    } catch (_) {
      return null;
    }
  }
}
