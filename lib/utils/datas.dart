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
