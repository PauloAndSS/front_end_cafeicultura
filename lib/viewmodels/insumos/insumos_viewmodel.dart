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

  Future<void> abrirDetalhe(int id) {
    if (_cargaDetalhe.isLoading) return Future.value();

    return _cargaDetalhe.executar(
      chamada: () async {
        _insumoDetalhe = await _serviceInsumo.buscarPorId(id);
      },
      aoFalhar: () {},
    );
  }

  Future<Insumo?> registrarCompra({
    required Insumo insumo,
    required Despesa despesa,
    required double qtdComprada,
  }) {
    if (_cargaCompra.isLoading) return Future.value(null);

    return _cargaCompra.executar<Insumo?>(
      chamada: () async {
        final resposta = await _serviceCompra.cadastrar(
          CompraDeInsumos.insumoExistente(
            insumo: insumo,
            despesa: despesa,
            qtdComprada: qtdComprada,
          ),
        );

        return _refletirCompra(insumo, resposta);
      },
      aoFalhar: () => null,
    );
  }

  Future<Insumo?> _refletirCompra(Insumo comprado, Insumo? resposta) async {
    if (resposta != null && resposta.qtdEstoque != null) {
      substituirInsumo(resposta);
      _sincronizarDetalhe(resposta);

      return resposta;
    }

    await carregarInsumos();

    final atualizado = insumos.firstWhere(
      (insumo) => insumo.id == comprado.id,
      orElse: () => resposta ?? comprado,
    );

    _sincronizarDetalhe(atualizado);

    return atualizado;
  }

  void _sincronizarDetalhe(Insumo atualizado) {
    if (_insumoDetalhe?.id != atualizado.id) return;

    _insumoDetalhe = atualizado;
  }
}
