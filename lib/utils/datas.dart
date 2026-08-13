// Comparação de datas ignorando a hora.
//
// Mora aqui, e não em `formatadores.dart`, porque não é apresentação: as
// regras de agendamento — "começa no futuro", "termina no máximo hoje" —
// comparam dias, e um `DateTime.now()` cru carrega hora, minuto e segundo.
// Sem normalizar, uma atividade que começa hoje às 00:00 seria "anterior a
// agora" e uma escolhida no calendário para hoje seria "posterior a agora"
// dependendo apenas da hora em que o app é aberto.

/// Meia-noite do dia da [data], no fuso local.
DateTime apenasData(DateTime data) => DateTime(data.year, data.month, data.day);

/// Meia-noite de hoje, no fuso local.
DateTime hoje() => apenasData(DateTime.now());

/// `true` quando a [data] cai depois de hoje — o critério de agendamento.
bool ehFutura(DateTime data) => apenasData(data).isAfter(hoje());
