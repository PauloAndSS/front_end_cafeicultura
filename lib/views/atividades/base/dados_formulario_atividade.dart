import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

class DadosFormularioAtividade {
  final int idTalhao;

  final int idSafra;

  final DateTime dataInicio;
  final DateTime? dataFim;
  final String? descricao;
  final List<Pessoa> responsaveis;
  final List<Despesa> despesas;

  const DadosFormularioAtividade({
    required this.idTalhao,
    required this.idSafra,
    required this.dataInicio,
    this.dataFim,
    this.descricao,
    this.responsaveis = const [],
    this.despesas = const [],
  });
}
