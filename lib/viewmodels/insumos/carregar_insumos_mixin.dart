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

  int? _idPropriedadeCarregada;

  bool _desatualizado = false;

  int _geracaoSincronizada = 0;

  bool insumosCarregadosDe(int idPropriedade) =>
      _idPropriedadeCarregada == idPropriedade && !_desatualizado;

  void marcarInsumosDesatualizados() => _desatualizado = true;

  void sincronizarCom(int geracaoDoCache) {
    if (geracaoDoCache == _geracaoSincronizada) return;

    _geracaoSincronizada = geracaoDoCache;
    _desatualizado = true;
  }

  bool get isCarregandoInsumos => _cargaInsumos.isLoading;

  bool get isCadastrandoInsumo => _cargaCadastro.isLoading;

  String? get mensagemErroInsumos => _cargaInsumos.mensagemErro;

  Future<void> carregarInsumos({required int idPropriedade}) {
    if (_cargaInsumos.isLoading) return Future.value();

    return _cargaInsumos.executar(
      chamada: () async {
        _descartarCatalogoDeOutraPropriedade(idPropriedade);

        final catalogo = await _insumoService.buscarPorPropriedade(
          idPropriedade: idPropriedade,
        );

        _insumos
          ..clear()
          ..addAll(catalogo.where((insumo) => insumo.id != null));

        _idPropriedadeCarregada = idPropriedade;
        _desatualizado = false;
      },
      aoFalhar: () {},
    );
  }

  Future<Insumo?> cadastrarInsumo({
    required int idPropriedade,
    required String descricao,
    required MedidaInsumo medida,
    required Despesa despesa,
    required double qtdComprada,
  }) {
    return _cargaCadastro.executar<Insumo?>(
      chamada: () async {
        final novo = Insumo(descricao: descricao.trim(), medida: medida);

        final registrada = await _compraService.cadastrar(
          CompraDeInsumos.novoInsumo(
            insumo: novo,
            despesa: despesa,
            qtdComprada: qtdComprada,
          ),
        );

        return registrada
            ? _recuperarCriado(novo.descricao, idPropriedade)
            : _comprarExistente(
                descricao: novo.descricao,
                idPropriedade: idPropriedade,
                despesa: despesa,
                qtdComprada: qtdComprada,
              );
      },
      aoFalhar: () => null,
    );
  }

  Future<Insumo?> _recuperarCriado(String descricao, int idPropriedade) async {
    final criado = await _insumoService.buscarPorDescricao(
      descricao: descricao,
      idPropriedade: idPropriedade,
    );

    if (criado == null) {
      _cargaCadastro.mensagemErro =
          'A compra foi registrada, mas não foi possível recuperar o insumo. Abra o seletor novamente.';
      return null;
    }

    _registrarNaLista(criado);

    return criado;
  }

  Future<Insumo?> _comprarExistente({
    required String descricao,
    required int idPropriedade,
    required Despesa despesa,
    required double qtdComprada,
  }) async {
    final existente = await _insumoService.buscarPorDescricao(
      descricao: descricao,
      idPropriedade: idPropriedade,
    );

    final id = existente?.id;

    if (existente == null || id == null) {
      _cargaCadastro.mensagemErro =
          'Já existe um insumo com essa descrição, mas ele não foi localizado para receber a compra.';
      return null;
    }

    await _compraService.cadastrar(
      CompraDeInsumos.insumoExistente(
        insumo: existente,
        despesa: despesa,
        qtdComprada: qtdComprada,
      ),
    );

    final comSaldo = await _insumoService.buscarPorId(
      id,
      idPropriedade: idPropriedade,
    );

    final atualizado = comSaldo ?? existente;

    _registrarNaLista(atualizado);

    return atualizado;
  }

  void _registrarNaLista(Insumo insumo) {
    if (_insumos.any((atual) => atual.id == insumo.id)) {
      substituirInsumo(insumo);
      return;
    }

    _insumos.add(insumo);

    notificarSeVivo();
  }

  void substituirInsumo(Insumo atualizado) {
    final indice = _insumos.indexWhere((insumo) => insumo.id == atualizado.id);

    if (indice < 0) return;

    _insumos[indice] = atualizado;

    notificarSeVivo();
  }

  void _descartarCatalogoDeOutraPropriedade(int idPropriedade) {
    if (_idPropriedadeCarregada == idPropriedade) return;

    _idPropriedadeCarregada = null;
    _insumos.clear();
  }
}
