import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class DetalhesTalhaoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final _talhaoService = ServicesTalhao();

  Future<bool> encerrar(int idTalhao, DateTime dataFim) => cargaPrincipal.executar(
        chamada: () => _talhaoService.encerrar(idTalhao, dataFim),
        aoFalhar: () => false,
      );

  Future<bool> excluir(int id) => cargaPrincipal.executar(
        chamada: () => _talhaoService.excluir(id),
        aoFalhar: () => false,
      );
}
