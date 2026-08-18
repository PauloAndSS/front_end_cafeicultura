import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

//atributos que todos os formulário de atividades tem em comum. Serve apenas para a view.

class DadosFormularioAtividade {
  final int idTalhao;

  /// Safra em que o lançamento entra.
  ///
  /// Fica aqui, e não no formulário do tipo concreto, porque safra é atributo
  /// de `Evento` — toda atividade agrícola nasce dentro de uma.
  final int idSafra;

  final DateTime dataInicio;
  final DateTime? dataFim;
  final String? descricao;
  final List<Pessoa> responsaveis;

  const DadosFormularioAtividade({
    required this.idTalhao,
    required this.idSafra,
    required this.dataInicio,
    this.dataFim,
    this.descricao,
    this.responsaveis = const [],
  });
}
