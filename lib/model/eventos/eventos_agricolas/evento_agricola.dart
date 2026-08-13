import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
export 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
export 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

abstract class EventoAgricola extends Evento {
  final int idTalhao;

  EventoAgricola({
    super.id,
    required super.dataInicio,
    super.dataFim,
    super.descricao,
    super.dataCadastro,
    super.idSafra,
    super.responsaveis,
    required this.idTalhao,
  });

  EventoAgricola.fromJson(super.json)
      : idTalhao = json['idTalhao'] ?? 0,
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'idTalhao': idTalhao,
    };
  }
}
