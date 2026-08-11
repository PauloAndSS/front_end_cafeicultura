import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

//atributos que todos os formulário de atividades tem em comum. Serve apenas para a view.

class DadosFormularioAtividade {
  final int idTalhao;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final String? descricao;
  final List<Pessoa> responsaveis;

  const DadosFormularioAtividade({
    required this.idTalhao,
    required this.dataInicio,
    this.dataFim,
    this.descricao,
    this.responsaveis = const [],
  });
}
