import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_insumo.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Catálogo de insumos do proprietário, compartilhado pelas atividades.
///
/// Toda atividade agrícola lança insumo do mesmo jeito e o seletor
/// `mostrarSelecaoInsumos` consome exatamente esta interface — por isso o
/// carregamento vive aqui e não dentro de um ViewModel específico.
///
/// Sem paginação: a rota devolve o catálogo inteiro numa tacada.
mixin CarregarInsumosMixin on DescarteSeguroMixin {
  final _insumoService = ServicesInsumo();

  final List<Insumo> _insumos = [];
  List<Insumo> get insumos => List.unmodifiable(_insumos);

  bool _insumosCarregados = false;
  bool get insumosCarregados => _insumosCarregados;

  bool _isCarregandoInsumos = false;
  bool get isCarregandoInsumos => _isCarregandoInsumos;

  bool _isCadastrandoInsumo = false;
  bool get isCadastrandoInsumo => _isCadastrandoInsumo;

  String? _mensagemErroInsumos;
  String? get mensagemErroInsumos => _mensagemErroInsumos;

  Future<void> carregarInsumos() async {
    if (_isCarregandoInsumos) return;

    _isCarregandoInsumos = true;
    _mensagemErroInsumos = null;
    notificarComSeguranca();

    try {
      final catalogo = await _insumoService.buscarTodos();

      _insumos
        ..clear()
        ..addAll(catalogo.where((insumo) => insumo.id != null));

      _insumosCarregados = true;
    } on ApiException catch (e) {
      _mensagemErroInsumos = e.mensagem;
    } catch (e) {
      _mensagemErroInsumos =
          'Ocorreu um erro interno ao carregar os insumos. Tente novamente mais tarde.';
    } finally {
      _isCarregandoInsumos = false;
      notificarComSeguranca();
    }
  }

  /// Cadastra e já devolve o insumo com id, para o seletor poder pedir a
  /// quantidade em seguida.
  ///
  /// Devolve `null` em caso de erro — a mensagem fica em
  /// [mensagemErroInsumos].
  Future<Insumo?> cadastrarInsumo({
    required int idProprietario,
    required String descricao,
    required MedidaInsumo medida,
  }) async {
    _isCadastrandoInsumo = true;
    _mensagemErroInsumos = null;
    notificarComSeguranca();

    try {
      final novo = Insumo(descricao: descricao.trim(), medida: medida);

      final criado = await _insumoService.cadastrar(novo, idProprietario) ??
          await _recuperarPorDescricao(novo.descricao);

      if (criado == null) {
        _mensagemErroInsumos =
            'O insumo foi cadastrado, mas não foi possível recuperá-lo. Abra o seletor novamente.';
        return null;
      }

      _insumos.add(criado);
      return criado;
    } on ApiException catch (e) {
      _mensagemErroInsumos = e.mensagem;
      return null;
    } catch (e) {
      _mensagemErroInsumos =
          'Ocorreu um erro interno ao cadastrar o insumo. Tente novamente mais tarde.';
      return null;
    } finally {
      _isCadastrandoInsumo = false;
      notificarComSeguranca();
    }
  }

  /// Rede de segurança para quando o POST não devolve o registro criado: o id
  /// é indispensável para vincular o insumo ao trato.
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
