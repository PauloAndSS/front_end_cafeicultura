import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class CadastrarTalhaoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final _talhaoService = ServicesTalhao();

  late final EstadoDeCarga _cargaVariedades = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  bool get isLoadingVariedades => _cargaVariedades.isLoading;

  List<Variedade> _variedades = [];
  List<Variedade> get variedades => _variedades;

  Future<void> carregarVariedades() => _cargaVariedades.executar(
        chamada: () async {
          _variedades = await _talhaoService.buscarVariedades();
        },
        aoFalhar: () {},
      );

  Future<bool> cadastrarTalhao(Talhao talhao) => cargaPrincipal.executar(
        chamada: () => _talhaoService.cadastrar(talhao),
        aoFalhar: () => false,
      );
}
