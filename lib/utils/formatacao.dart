import 'package:intl/intl.dart';

final _dataCurta = DateFormat('dd/MM/yyyy');

final _anoMes = DateFormat('yyyy/MM');

final _dataExtensa = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');

final _mesAno = DateFormat.yMMMM('pt_BR');

final _mesAbreviado = DateFormat.MMM('pt_BR');

String formatarDataBr(DateTime data) => _dataCurta.format(data);

String formatarAnoMes(DateTime data) => _anoMes.format(data);

String formatarDataExtensa(DateTime data) => _dataExtensa.format(data);

String formatarMesAnoExtenso(DateTime data) => capitalizar(_mesAno.format(data));

String formatarMesAbreviado(DateTime data) => _mesAbreviado.format(data);

String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

final _inteiroBr = NumberFormat('#,##0', 'pt_BR');

final _decimalBr = NumberFormat('#,##0.##', 'pt_BR');

String formatarInteiro(num valor) => _inteiroBr.format(valor);
String formatarDecimal(num valor) => _decimalBr.format(valor);

final _moedaBr = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatarMoeda(num valor) => _moedaBr.format(valor);
