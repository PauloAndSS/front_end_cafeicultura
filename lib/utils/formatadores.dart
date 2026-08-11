import 'package:intl/intl.dart';

/// Formatação de data no padrão pt-BR, compartilhada pelos models.
///
/// Mora aqui, e não como estático em algum model, porque a tela também formata
/// data que não pertence a entidade nenhuma — a escolhida no calendário antes
/// de o objeto existir.

final _dataCurta = DateFormat('dd/MM/yyyy');

final _anoMes = DateFormat('yyyy/MM');

/// 31/12/2025
String formatarDataBr(DateTime data) => _dataCurta.format(data);

/// 2025/12 — usado onde a data serve para desambiguar nome, não para exibir.
String formatarAnoMes(DateTime data) => _anoMes.format(data);
