import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';

// Intervalo de datas que definem onde temporalmente um talhão e uma safra existem, para permitir que o usuário consiga cadastrar uma atividade na data desejada. Se não há coexistência de talhão e safra nesse período de data de início e fim da atividade, ele não pode cadastrá-la.
class Periodo {
  final DateTime inicio;
  final DateTime? fim;

  Periodo({required DateTime inicio, DateTime? fim})
      : inicio = apenasData(inicio),
        fim = fim == null ? null : apenasData(fim);

  bool get emAberto => fim == null;

  bool contem(DateTime dia) {
    final data = apenasData(dia);

    if (data.isBefore(inicio)) return false;

    return fim == null || !data.isAfter(fim!);
  }

  Periodo? intersecao(Periodo outro) {
    final inicioMaior = inicio.isAfter(outro.inicio) ? inicio : outro.inicio;
    final fimMenor = menorData(fim, outro.fim);

    if (fimMenor != null && fimMenor.isBefore(inicioMaior)) return null;

    return Periodo(inicio: inicioMaior, fim: fimMenor);
  }

  @override
  String toString() => 'Periodo($inicio → ${fim ?? 'em aberto'})';
}
