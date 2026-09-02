import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';

class InsumosViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, CarregarInsumosMixin, CarregarPessoasMixin {
  final _serviceInsumo = ServicesInsumo();

  final _serviceCompra = ServicesCompraInsumo();

  late final EstadoDeCarga _cargaDetalhe = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  late final EstadoDeCarga _cargaCompra = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  Insumo? _insumoDetalhe;
  Insumo? get insumoDetalhe => _insumoDetalhe;

  bool get isCarregandoDetalhe => _cargaDetalhe.isLoading;

  String? get mensagemErroDetalhe => _cargaDetalhe.mensagemErro;

  bool get isRegistrandoCompra => _cargaCompra.isLoading;

  String? get mensagemErroCompra => _cargaCompra.mensagemErro;

  Future<void> abrirDetalhe(int id, {required int idPropriedade}) {
    if (_cargaDetalhe.isLoading) return Future.value();

    return _cargaDetalhe.executar(
      chamada: () async {
        _insumoDetalhe =
            await _serviceInsumo.buscarPorId(id, idPropriedade: idPropriedade);
      },
      aoFalhar: () {},
    );
  }

  Future<Insumo?> registrarCompra({
    required Insumo insumo,
    required int idPropriedade,
    required Despesa despesa,
    required double qtdComprada,
  }) {
    if (_cargaCompra.isLoading) return Future.value(null);

    return _cargaCompra.executar<Insumo?>(
      chamada: () async {
        await _serviceCompra.cadastrar(
          CompraDeInsumos.insumoExistente(
            insumo: insumo,
            despesa: despesa,
            qtdComprada: qtdComprada,
          ),
        );

        return _relerSaldo(insumo, idPropriedade);
      },
      aoFalhar: () => null,
    );
  }

  Future<Insumo> _relerSaldo(Insumo comprado, int idPropriedade) async {
    final id = comprado.id;

    final relido = id == null
        ? null
        : await _serviceInsumo.buscarPorId(id, idPropriedade: idPropriedade);

    final atualizado = relido ?? comprado;

    substituirInsumo(atualizado);
    _sincronizarDetalhe(atualizado);

    return atualizado;
  }

  void _sincronizarDetalhe(Insumo atualizado) {
    if (_insumoDetalhe?.id != atualizado.id) return;

    _insumoDetalhe = atualizado;
  }
}
