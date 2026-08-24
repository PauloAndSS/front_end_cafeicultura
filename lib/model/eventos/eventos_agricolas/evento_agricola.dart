import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
export 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
export 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

class EventoAgricola extends Evento {
  final int idTalhao;

  final String modulo;

  EventoAgricola({
    super.id,
    required super.dataInicio,
    super.dataFim,
    super.descricao,
    super.dataCadastro,
    super.idSafra,
    super.responsaveis,
    required this.idTalhao,
    this.modulo = '',
  });

  EventoAgricola.fromJson(super.json, {this.modulo = ''})
      : idTalhao = json['idTalhao'],
        super.fromJson();

  @override
  String get tituloExibicao => rotuloDeModulo(modulo);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'idTalhao': idTalhao,
    };
  }
}

enum ModuloEvento {
  tratoCultural('TRATO_CULTURAL', 'Trato cultural');

  const ModuloEvento(this.codigoApi, this.rotulo);

  final String codigoApi;

  final String rotulo;

  static ModuloEvento? deCodigo(String? codigo) {
    for (final modulo in values) {
      if (modulo.codigoApi == codigo) return modulo;
    }

    return null;
  }
}

String rotuloDeModulo(String codigo) =>
    ModuloEvento.deCodigo(codigo)?.rotulo ?? _tipoEventoFormatado(codigo);

String _tipoEventoFormatado(String codigo) {
  final palavras = codigo.toLowerCase().split('_').where((p) => p.isNotEmpty);

  if (palavras.isEmpty) return 'Atividade';

  final primeira = palavras.first;

  return [capitalizar(primeira), ...palavras.skip(1)].join(' ');
}
