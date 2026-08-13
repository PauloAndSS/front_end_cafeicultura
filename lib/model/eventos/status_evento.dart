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
}
