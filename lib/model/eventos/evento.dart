import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

enum StatusEvento {
  agendado(
    rotulo: 'Agendado',
    filtro: 'Agendadas',
    filtroCurto: 'Agendadas',
    codigoApi: 'agendados',
  ),
  emAndamento(
    rotulo: 'Em andamento',
    filtro: 'Em andamento',
    filtroCurto: 'Andamento',
    codigoApi: 'em_andamento',
  ),
  finalizado(
    rotulo: 'Finalizado',
    filtro: 'Finalizadas',
    filtroCurto: 'Finalizadas',
    codigoApi: 'finalizados',
  );

  const StatusEvento({
    required this.rotulo,
    required this.filtro,
    required this.filtroCurto,
    required this.codigoApi,
  });

  final String rotulo;

  final String filtro;

  final String filtroCurto;

  final String codigoApi;
}

String rotuloDeFiltro(StatusEvento? status, {bool curto = false}) {
  if (status == null) return 'Todas';

  return curto ? status.filtroCurto : status.filtro;
}

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
        dataInicio = lerDataDoJson(json['dataInicio']) ?? DateTime.now(),
        dataFim = lerDataDoJson(json['dataFim']),
        descricao = json['descricao'],
        dataCadastro = lerDataDoJson(json['dataCadastro']),
        idSafra = _lerIdSafra(json),
        responsaveis = _lerResponsaveis(json);

  String get tituloExibicao;

  StatusEvento get status {
    if (dataFim != null) return StatusEvento.finalizado;

    return ehFutura(dataInicio)
        ? StatusEvento.agendado
        : StatusEvento.emAndamento;
  }

  bool get finalizado => status == StatusEvento.finalizado;

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
      'dataInicio': dataParaJson(dataInicio),
      if (dataFim != null) 'dataFim': dataParaJson(dataFim!),
      if (descricaoLimpa.isNotEmpty) 'descricao': descricaoLimpa,
      if (idSafra != null) 'idSafra': idSafra,
      'responsaveisIds': responsaveis
          .map((pessoa) => pessoa.id)
          .whereType<int>()
          .toList(),
    };
  }

  static int _lerIdSafra(Map<String, dynamic> json) {
    return json['safra'] is Map<String, dynamic> ? json['safra']['id'] : json['idSafra'];
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
