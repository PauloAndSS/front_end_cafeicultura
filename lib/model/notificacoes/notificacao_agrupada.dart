import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';

export 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao.dart';

class NotificacaoAgrupada {
  final Notificacao representante;
  final List<int> ids;
  final bool lida;

  const NotificacaoAgrupada({
    required this.representante,
    required this.ids,
    required this.lida,
  });

  int get idEvento => representante.idEvento;

  TipoEventoNotificado? get tipoEvento => representante.tipoEvento;

  TipoNotificacao? get tipoNotificacao => representante.tipoNotificacao;

  bool get ehConfirmacao => representante.ehConfirmacao;

  DateTime get dataCriacao => representante.dataCriacao;

  DateTime get dataPrevistaDoEvento => representante.dataPrevistaDoEvento;

  int get repeticoes => ids.length;

  NotificacaoAgrupada comoLida() => NotificacaoAgrupada(
        representante: representante,
        ids: ids,
        lida: true,
      );

  static List<NotificacaoAgrupada> agrupar(List<Notificacao> notificacoes) {
    final porChave = <String, _Acumulador>{};

    for (final notificacao in notificacoes) {
      if (!notificacao.ehInterpretavel) continue;

      final acumulador = porChave.putIfAbsent(
        notificacao.chaveDeAgrupamento,
        () => _Acumulador(notificacao),
      );

      acumulador.somar(notificacao);
    }

    return porChave.values.map((acumulador) => acumulador.fechar()).toList();
  }
}

class _Acumulador {
  _Acumulador(this._representante);

  Notificacao _representante;
  final List<int> _ids = [];
  bool _algumaNaoLida = false;

  void somar(Notificacao notificacao) {
    _ids.add(notificacao.id);

    if (!notificacao.lida) _algumaNaoLida = true;

    if (notificacao.dataCriacao.isAfter(_representante.dataCriacao)) {
      _representante = notificacao;
    }
  }

  NotificacaoAgrupada fechar() => NotificacaoAgrupada(
        representante: _representante,
        ids: List.unmodifiable(_ids),
        lida: !_algumaNaoLida,
      );
}
