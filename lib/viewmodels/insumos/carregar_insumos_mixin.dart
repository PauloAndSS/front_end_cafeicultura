import 'package:frond_end_cafeicultura_mobile/http/services/services_compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/compra_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

mixin CarregarInsumosMixin on NotificaSeVivoMixin {
  final _insumoService = ServicesInsumo();

  final _compraService = ServicesCompraInsumo();

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
    required Despesa despesa,
    required double qtdComprada,
  }) {
    return _cargaCadastro.executar<Insumo?>(
      chamada: () async {
        final novo = Insumo(descricao: descricao.trim(), medida: medida);

        final criado = await _compraService.cadastrar(
              CompraDeInsumos.novoInsumo(
                idProprietario: idProprietario,
                insumo: novo,
                despesa: despesa,
                qtdComprada: qtdComprada,
              ),
            ) ??
            await _recuperarPorDescricao(novo.descricao);

        if (criado == null) {
          _cargaCadastro.mensagemErro =
              'A compra foi registrada, mas não foi possível recuperar o insumo. Abra o seletor novamente.';
          return null;
        }

        _insumos.add(criado);

        return criado;
      },
      aoFalhar: () => null,
    );
  }

  void substituirInsumo(Insumo atualizado) {
    final indice = _insumos.indexWhere((insumo) => insumo.id == atualizado.id);

    if (indice < 0) return;

    _insumos[indice] = atualizado;

    notificarSeVivo();
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
