import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class RelatorioTalhaoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final ServicesSafra _service = ServicesSafra();

  List<EventoAgricola> _eventos = [];
  Safra? _safraSelecionada;

  int? _idPropriedade;
  int? _idTalhao;

  List<EventoAgricola> get eventos => _eventos;
  Safra? get safraSelecionada => _safraSelecionada;

  Future<void> selecionarSafra(
    Safra safra, {
    required int idPropriedade,
    required int idTalhao,
  }) async {
    final mesmaSafra = _safraSelecionada?.id == safra.id;
    final mesmoEscopo = _idPropriedade == idPropriedade && _idTalhao == idTalhao;

    if (mesmaSafra && mesmoEscopo) {
      return;
    }

    _safraSelecionada = safra;
    _idPropriedade = idPropriedade;
    _idTalhao = idTalhao;
    _eventos = [];
    notificarSeVivo();

    await recarregar();
  }

  Future<void> recarregar() {
    final idPropriedade = _idPropriedade;
    final idTalhao = _idTalhao;
    final idSafra = _safraSelecionada?.id;

    if (idPropriedade == null || idTalhao == null || idSafra == null) {
      return Future.value();
    }

    return cargaPrincipal.executar(
      chamada: () async {
        final eventos = await _service.buscarRelatorioDoTalhao(
          idPropriedade: idPropriedade,
          idSafra: idSafra,
          idTalhao: idTalhao,
        );

        if (_respostaAindaVale(idSafra)) _eventos = eventos;
      },
      aoFalhar: () {},
      aindaVale: () => _respostaAindaVale(idSafra),
    );
  }

  bool _respostaAindaVale(int idSafra) => _safraSelecionada?.id == idSafra;
}
