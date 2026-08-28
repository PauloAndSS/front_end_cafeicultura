DateTime apenasData(DateTime data) => DateTime(data.year, data.month, data.day);

DateTime hoje() => apenasData(DateTime.now());

bool ehFutura(DateTime data) => apenasData(data).isAfter(hoje());

DateTime diaSeguinte(DateTime data) =>
    DateTime(data.year, data.month, data.day + 1);

DateTime? menorData(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;

  return a.isBefore(b) ? a : b;
}

DateTime? maiorData(DateTime? a, DateTime? b) {
  if (a == null || b == null) return null;

  return a.isAfter(b) ? a : b;
}

DateTime? lerDataDoJson(dynamic valor) {
  if (valor == null) return null;
  if (valor is DateTime) return valor;

  if (valor is num) {
    return DateTime.fromMillisecondsSinceEpoch(valor.toInt(), isUtc: true);
  }

  return DateTime.tryParse(valor.toString());
}

String dataParaJson(DateTime data) =>
    DateTime.utc(data.year, data.month, data.day, 12).toIso8601String();

String instanteParaJson(DateTime instante) =>
    instante.toUtc().toIso8601String();

/// Folga entre o relógio do aparelho e o do servidor.
const Duration margemDeRelogio = Duration(minutes: 5);

/// Marca um dia para rota que o backend recusa quando a data parece futura.
///
/// Só o dia de hoje troca o marcador de [dataParaJson] por um instante recuado
/// de [margemDeRelogio], com piso no início do dia local — o dia devolvido é
/// sempre o dia que entrou. Passe [agora] quando dois campos do mesmo corpo
/// precisarem do mesmo instante. O porquê está em `lib/utils/CLAUDE.md`.
String diaNaoFuturoParaJson(DateTime data, {DateTime? agora}) {
  final instante = agora ?? DateTime.now();

  if (!apenasData(data).isAtSameMomentAs(apenasData(instante))) {
    return dataParaJson(data);
  }

  final marcador = DateTime.utc(data.year, data.month, data.day, 12);
  final teto = instante.toUtc().subtract(margemDeRelogio);

  if (!marcador.isAfter(teto)) return marcador.toIso8601String();

  final inicioDoDia = apenasData(instante).toUtc();

  return (teto.isBefore(inicioDoDia) ? inicioDoDia : teto).toIso8601String();
}
