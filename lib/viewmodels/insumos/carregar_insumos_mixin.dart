import 'package:frond_end_cafeicultura_mobile/http/services/services_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

mixin CarregarInsumosMixin on NotificaSeVivoMixin {
  final _insumoService = ServicesInsumo();

  late final EstadoDeCarga _cargaInsumos = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  late final EstadoDeCarga _cargaCadastro = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: _cargaInsumos,
  );

  final List<Insumo> _insumos = [];
  List<Insumo> get insumos => List.unmodifiable(_insumos);

  bool _insumosCarregados = false;
  bool get insumosCarregados => _insumosCarregados;

  bool get isCarregandoInsumos => _cargaInsumos.isLoading;

  bool get isCadastrandoInsumo => _cargaCadastro.isLoading;

  String? get mensagemErroInsumos => _cargaInsumos.mensagemErro;

  Future<void> carregarInsumos() {
    if (_cargaInsumos.isLoading) return Future.value();

    return _cargaInsumos.executar(
      chamada: () async {
        final catalogo = await _insumoService.buscarTodos();

        _insumos
          ..clear()
          ..addAll(catalogo.where((insumo) => insumo.id != null));

        _insumosCarregados = true;
      },
      aoFalhar: () {},
    );
  }

  Future<Insumo?> cadastrarInsumo({
    required int idProprietario,
    required String descricao,
    required MedidaInsumo medida,
  }) {
    return _cargaCadastro.executar<Insumo?>(
      chamada: () async {
        final novo = Insumo(descricao: descricao.trim(), medida: medida);

        final criado = await _insumoService.cadastrar(novo, idProprietario) ??
            await _recuperarPorDescricao(novo.descricao);

        if (criado == null) {
          _cargaCadastro.mensagemErro =
              'O insumo foi cadastrado, mas não foi possível recuperá-lo. Abra o seletor novamente.';
          return null;
        }

        _insumos.add(criado);
        return criado;
      },
      aoFalhar: () => null,
    );
  }

  Future<Insumo?> _recuperarPorDescricao(String descricao) async {
    final catalogo = await _insumoService.buscarTodos();

    for (final insumo in catalogo.reversed) {
      if (insumo.id != null && insumo.descricao.trim() == descricao) {
        return insumo;
      }
    }

    return null;
  }
}
