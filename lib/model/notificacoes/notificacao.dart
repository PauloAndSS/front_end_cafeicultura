import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';

String rotuloDeHorizonte(DateTime dia) {
  final dias = diasAPartirDeHoje(dia);

  return switch (dias) {
    0 => 'Hoje',
    1 => 'Amanhã',
    -1 => 'Começou ontem',
    < 0 => 'Começou há ${-dias} dias',
    _ => 'Em $dias dias',
  };
}

String textoDeQuando(DateTime dia) =>
    '${rotuloDeHorizonte(dia)} · ${formatarDataComDiaDaSemana(dia)}';

enum TipoNotificacao {
  futuroSete('FUTURO_SETE', 7),
  futuroTres('FUTURO_TRES', 3),
  futuroDois('FUTURO_DOIS', 2),
  futuroUm('FUTURO_UM', 1),
  passado('PASSADO', -1);

  const TipoNotificacao(this.codigoApi, this.diasAteEvento);

  final String codigoApi;

  final int diasAteEvento;

  bool get ehConfirmacao => this == TipoNotificacao.passado;

  String get rotulo => switch (this) {
        TipoNotificacao.passado => 'Ocorreu?',
        TipoNotificacao.futuroUm => 'Amanhã',
        _ => 'Em $diasAteEvento dias',
      };

  static TipoNotificacao? deCodigo(String? codigo) {
    for (final tipo in values) {
      if (tipo.codigoApi == codigo) return tipo;
    }

    return null;
  }
}

enum TipoEventoNotificado {
  tratosCulturais('tratosculturais', 'Trato cultural', temTelaPropria: true),
  colheitas('colheitas', 'Colheita'),
  fermentacoes('fermentacoes', 'Fermentação'),
  preSecagens('presecagens', 'Pré-secagem'),
  secagens('secagens', 'Secagem'),
  pilagens('pilagens', 'Pilagem'),
  armazenagens('armazenagens', 'Armazenagem'),
  vendas('vendas', 'Venda');

  const TipoEventoNotificado(
    this.codigoApi,
    this.rotulo, {
    this.temTelaPropria = false,
  });

  final String codigoApi;

  final String rotulo;

  final bool temTelaPropria;

  static TipoEventoNotificado? deCodigo(String? codigo) {
    for (final tipo in values) {
      if (tipo.codigoApi == codigo) return tipo;
    }

    return null;
  }
}

class Notificacao {
  final int id;
  final int idProprietario;
  final int idPropriedade;
  final int idEvento;
  final TipoEventoNotificado? tipoEvento;
  final TipoNotificacao? tipoNotificacao;
  final DateTime dataCriacao;
  final bool lida;

  Notificacao({
    required this.id,
    required this.idProprietario,
    required this.idPropriedade,
    required this.idEvento,
    required this.tipoEvento,
    required this.tipoNotificacao,
    required this.dataCriacao,
    required this.lida,
  });

  Notificacao.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        idProprietario = json['idProprietario'],
        idPropriedade = json['idPropriedade'],
        idEvento = json['idEvento'],
        tipoEvento = TipoEventoNotificado.deCodigo(json['tipoEvento']),
        tipoNotificacao = TipoNotificacao.deCodigo(json['tipoNotificacao']),
        dataCriacao = lerDataDoJson(json['dataCriacao']) ?? DateTime.now(),
        lida = json['lida'] == true;

  Notificacao comoLida() => Notificacao(
        id: id,
        idProprietario: idProprietario,
        idPropriedade: idPropriedade,
        idEvento: idEvento,
        tipoEvento: tipoEvento,
        tipoNotificacao: tipoNotificacao,
        dataCriacao: dataCriacao,
        lida: true,
      );

  bool get ehConfirmacao => tipoNotificacao?.ehConfirmacao ?? false;

  bool get ehInterpretavel => tipoNotificacao != null;

  DateTime get dataPrevistaDoEvento {
    final dia = apenasData(dataCriacao.toLocal());
    final deslocamento = tipoNotificacao?.diasAteEvento ?? 0;

    return DateTime(dia.year, dia.month, dia.day + deslocamento);
  }

  String get dataPrevistaFormatada => formatarDataBr(dataPrevistaDoEvento);

  String get tituloGenerico => tipoEvento?.rotulo ?? 'Atividade';

  String get chaveDeAgrupamento =>
      '$idEvento|${tipoEvento?.codigoApi}|${tipoNotificacao?.codigoApi}';
}
