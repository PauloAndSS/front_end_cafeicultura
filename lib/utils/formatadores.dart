import 'package:intl/intl.dart';

/// Formatação de data no padrão pt-BR, compartilhada pelos models.
///
/// Mora aqui, e não como estático em algum model, porque a tela também formata
/// data que não pertence a entidade nenhuma — a escolhida no calendário antes
/// de o objeto existir.

final _dataCurta = DateFormat('dd/MM/yyyy');

final _anoMes = DateFormat('yyyy/MM');

final _dataExtensa = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');

final _mesAno = DateFormat.yMMMM('pt_BR');

final _mesAbreviado = DateFormat.MMM('pt_BR');

/// 31/12/2025
String formatarDataBr(DateTime data) => _dataCurta.format(data);

/// 2025/12 — usado onde a data serve para desambiguar nome, não para exibir.
String formatarAnoMes(DateTime data) => _anoMes.format(data);

/// 31 de dezembro de 2025 — para títulos, onde a data curta fica seca.
///
/// Depende de `initializeDateFormatting('pt_BR')`, feito no `main`: com nome de
/// mês em jogo, o `intl` precisa dos símbolos da localidade carregados.
String formatarDataExtensa(DateTime data) => _dataExtensa.format(data);

/// Agosto de 2026 — cabeçalho de período, no calendário e na lista logo abaixo
/// dele.
///
/// O `intl` devolve "agosto de 2026" em minúscula, que serve para meio de frase
/// e não para título; a maiúscula entra aqui para as duas telas que usam o
/// texto não a escreverem cada uma do seu jeito.
String formatarMesAnoExtenso(DateTime data) => _capitalizar(_mesAno.format(data));

/// "jan", "fev"... — rótulo de eixo, onde nem o mês por extenso nem o
/// `dd/MM/yyyy` cabem.
///
/// Locale fixo em pt-BR pelo mesmo motivo do resto do arquivo: o app é de uma
/// localidade só, e depender do locale do aparelho faria o eixo divergir do
/// título logo acima dele.
String formatarMesAbreviado(DateTime data) => _mesAbreviado.format(data);

String _capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
