/// Situação de um evento no tempo.
///
/// Três estados, e não o par em andamento/finalizado: com o agendamento, um
/// evento sem data de término pode ainda não ter começado, e o que distingue
/// os dois casos é a data de início contra hoje.
///
/// É o mesmo enum que a listagem usa como filtro — o filtro é literalmente
/// "mostre os eventos neste status", e dois enums paralelos divergiriam.
enum StatusEvento { agendado, emAndamento, finalizado }

extension RotulosStatusEvento on StatusEvento {
  /// Selo do card e do cartão de detalhes.
  String get rotulo => switch (this) {
        StatusEvento.agendado => 'Agendado',
        StatusEvento.emAndamento => 'Em andamento',
        StatusEvento.finalizado => 'Finalizado',
      };

  /// Rótulo do filtro de listagem, no feminino plural de "atividades".
  String get rotuloFiltro => switch (this) {
        StatusEvento.agendado => 'Agendadas',
        StatusEvento.emAndamento => 'Em andamento',
        StatusEvento.finalizado => 'Finalizadas',
      };

  /// Valor do query param `status` nas rotas de atividade.
  ///
  /// Mora aqui, junto dos rótulos, e não no service: o enum é a fonte única do
  /// que significa cada estado, e um `switch` de tradução perdido na camada HTTP
  /// seria o quarto lugar a listar os mesmos três casos.
  ///
  /// Os valores não seguem o nome do enum — são os que o backend aceita.
  String get filtroApi => switch (this) {
        StatusEvento.agendado => 'agendados',
        StatusEvento.emAndamento => 'em_andamento',
        StatusEvento.finalizado => 'finalizados',
      };
}
