import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Listagem de atividades agrícolas de um mesmo tipo.
///
/// A base não conhece service: a busca entra por método abstrato nas variantes
/// abaixo. Foi essa a escolha em vez de closure de construtor porque o
/// `idPropriedade` só é conhecido depois que a View resolve o
/// `PropriedadesUsuarioViewModel` — capturá-lo numa closure obrigaria a recriar
/// o ViewModel a cada troca de propriedade, exatamente o que a guarda de escopo
/// existe para evitar.
abstract class ListaAtividadesViewModel<T extends EventoAgricola>
    extends ChangeNotifier with DescarteSeguroMixin {
  List<T> _atividades = [];
  List<T> get atividades => List.unmodifiable(_atividades);

  List<T> get emAndamento =>
      _atividades.where((atividade) => atividade.emAndamento).toList();

  List<T> get finalizadas =>
      _atividades.where((atividade) => !atividade.emAndamento).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  Object? _escopoCarregado;

  /// Mensagem do `catch` genérico. Termina antes de "Tente novamente" — a base
  /// completa a frase.
  @protected
  String get erroInternoAoCarregar;

  /// Carrega só se o [escopo] mudou, ou se [forcar].
  ///
  /// Uma guarda só substitui as duas que existiam antes — o `idPropriedadeAtual`
  /// da aba e o `_carregado` da seção do talhão são a mesma regra com chaves
  /// diferentes (um `int`, um registro `(idPropriedade, idTalhao)`; registros
  /// têm igualdade por valor).
  ///
  /// O escopo só é marcado em caso de sucesso, então erro sempre permite nova
  /// tentativa.
  @protected
  Future<void> carregarSe({
    required Object escopo,
    required Future<List<T>> Function() buscar,
    bool forcar = false,
  }) async {
    if (_isLoading) return;
    if (!forcar && escopo == _escopoCarregado) return;

    _isLoading = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      final lista = await buscar();
      lista.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));

      _atividades = lista;
      _escopoCarregado = escopo;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = '$erroInternoAoCarregar Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notificarComSeguranca();
    }
  }
}

/// Atividades de toda a propriedade — a aba.
///
/// Traz [CarregarTalhoesMixin] junto porque o payload da listagem só devolve
/// `idTalhao`: sem os talhões não há como o card mostrar o nome.
abstract class ListaAtividadesDaPropriedadeViewModel<
    T extends EventoAgricola> extends ListaAtividadesViewModel<T>
    with CarregarTalhoesMixin {
  @protected
  Future<List<T>> buscarNaPropriedade(int idPropriedade);

  Future<void> carregar(int idPropriedade, {bool forcar = false}) {
    return carregarSe(
      escopo: idPropriedade,
      forcar: forcar,
      buscar: () async {
        final buscaAtividades = buscarNaPropriedade(idPropriedade);
        final buscaTalhoes = carregarTalhoes(idPropriedade);

        // As duas em voo ao mesmo tempo. O `Future.wait` está aqui para anexar
        // handler nas duas de imediato — sem ele, um erro da busca que chegasse
        // enquanto os talhões ainda carregam seria reportado como "unhandled"
        // antes de o `catch` do [carregarSe] alcançá-lo. Ele repropaga a
        // exceção original, então a `ApiException` do backend sobrevive.
        //
        // O resultado da lista heterogênea é descartado: o valor tipado sai do
        // próprio future, já completo.
        await Future.wait([buscaAtividades, buscaTalhoes]);

        return buscaAtividades;
      },
    );
  }
}

/// Atividades de um talhão só — a seção dentro do detalhe do talhão.
///
/// Sem o mixin de talhões: quem abriu a tela já sabe o nome e o passa adiante.
abstract class ListaAtividadesDoTalhaoViewModel<
    T extends EventoAgricola> extends ListaAtividadesViewModel<T> {
  @protected
  Future<List<T>> buscarNoTalhao(int idPropriedade, int idTalhao);

  Future<void> carregar(
    int idPropriedade,
    int idTalhao, {
    bool forcar = false,
  }) {
    return carregarSe(
      escopo: (idPropriedade, idTalhao),
      forcar: forcar,
      buscar: () => buscarNoTalhao(idPropriedade, idTalhao),
    );
  }
}
