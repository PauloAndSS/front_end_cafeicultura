import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Atividades de uma propriedade **mês a mês**, com cache por mês.
///
/// É a base dos calendários, e por isso não herda de `ListaAtividadesViewModel`:
/// aquela guarda um escopo único e a coleção inteira, enquanto aqui o escopo é o
/// par (propriedade, mês) e o usuário navega entre vários deles na mesma sessão.
///
/// A granularidade é o **mês inteiro**. Andar dentro do mês não custa requisição
/// nenhuma, e a chave de cache é uma só em vez de uma por intervalo visível.
///
/// A subclasse fornece apenas [buscarNoPeriodo] — a rota muda (a home lê todos
/// os módulos, a aba de tratos lê só os tratos), o cache e a janela em UTC não.
abstract class AgendaMensalViewModel<T extends EventoAgricola>
    extends ChangeNotifier with DescarteSeguroMixin, CarregarTalhoesMixin {
  /// Atividades já buscadas, por `'<idPropriedade>|<ano/mês>'`.
  ///
  /// Cache de sessão, como o de `SafraViewModel`: dura enquanto o app estiver
  /// aberto e evita rebuscar um mês toda vez que o usuário volta a ele.
  final Map<String, List<T>> _cachePorMes = {};

  int? _idPropriedade;
  DateTime? _mesVisivel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// `true` até o primeiro mês terminar de carregar.
  ///
  /// Separado de [isLoading] porque a tela reage aos dois de formas diferentes:
  /// a primeira carga pode ocupar a área toda com um spinner, mas a troca de mês
  /// não pode — apagar a grade a cada navegação faria o calendário piscar.
  bool _carregouAlgumaVez = false;
  bool get carregouAlgumaVez => _carregouAlgumaVez;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  /// Mês exibido no calendário, sempre no dia 1º.
  DateTime? get mesVisivel => _mesVisivel;

  /// Atividades do mês visível. Lista vazia enquanto ele não tiver carregado.
  List<T> get atividadesDoMes {
    if (_idPropriedade == null || _mesVisivel == null) return const [];

    return _cachePorMes[_chave(_idPropriedade!, _mesVisivel!)] ?? const [];
  }

  /// Busca as atividades da janela — o que muda entre um calendário e outro.
  ///
  /// Os limites chegam **em UTC** e já cobrem o mês inteiro; a implementação só
  /// os repassa para a rota.
  @protected
  Future<List<T>> buscarNoPeriodo(
    int idPropriedade,
    DateTime inicio,
    DateTime fim,
  );

  /// Mensagem do `catch` genérico. Termina antes de "Tente novamente" — a base
  /// completa a frase.
  @protected
  String get erroInternoAoCarregar =>
      'Ocorreu um erro interno ao carregar as atividades.';

  /// Carrega o mês de [data], se ele ainda não estiver em cache.
  ///
  /// Pode ser chamado a cada troca de página do calendário — a guarda de cache
  /// absorve a repetição sem tocar na rede.
  Future<void> carregarMes(
    int idPropriedade,
    DateTime data, {
    bool forcar = false,
  }) async {
    final mes = _primeiroDiaDoMes(data);
    final chave = _chave(idPropriedade, mes);

    final mudouDeMes = _idPropriedade != idPropriedade || _mesVisivel != mes;

    _idPropriedade = idPropriedade;
    _mesVisivel = mes;

    if (!forcar && _cachePorMes.containsKey(chave)) {
      // Já temos o mês: só avisa a tela de que o recorte visível mudou.
      if (mudouDeMes) notificarComSeguranca();
      return;
    }

    if (_isLoading) return;

    _isLoading = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      _cachePorMes[chave] = await _buscarMesInteiro(idPropriedade, mes);
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = '$erroInternoAoCarregar Tente novamente mais tarde.';
      debugPrint('Erro ao carregar atividades do mês $chave: $e');
    } finally {
      _isLoading = false;
      _carregouAlgumaVez = true;
      notificarComSeguranca();
    }
  }

  /// Recarrega o mês visível ignorando o cache — usado pelo pull-to-refresh e
  /// depois de cadastrar ou editar uma atividade.
  Future<void> recarregarMesVisivel() {
    if (_idPropriedade == null || _mesVisivel == null) return Future.value();

    return carregarMes(_idPropriedade!, _mesVisivel!, forcar: true);
  }

  /// Esvazia o cache inteiro. Chamado ao trocar de propriedade — os meses da
  /// anterior não dizem nada sobre a nova.
  void limparCache() {
    _cachePorMes.clear();
    _mensagemErro = null;
    _carregouAlgumaVez = false;
    notificarComSeguranca();
  }

  /// Busca a janela do mês junto com os talhões.
  ///
  /// Os talhões vão junto porque o payload traz apenas `idTalhao` — sem eles o
  /// card não teria como exibir o nome.
  Future<List<T>> _buscarMesInteiro(int idPropriedade, DateTime mes) async {
    final buscaTalhoes = carregarTalhoes(idPropriedade);

    try {
      return await buscarNoPeriodo(
        idPropriedade,
        _primeiroInstanteDoMes(mes),
        _ultimoInstanteDoMes(mes),
      );
    } finally {
      // Aguarda sempre, inclusive quando a busca acima falha: o
      // `carregarTalhoes` já está em voo e nunca lança (guarda o erro em
      // `mensagemErroTalhoes`), então deixá-lo pendente só adiaria o trabalho
      // para um frame aleatório.
      await buscaTalhoes;
    }
  }

  String _chave(int idPropriedade, DateTime mes) =>
      '$idPropriedade|${formatarAnoMes(mes)}';

  DateTime _primeiroDiaDoMes(DateTime data) => DateTime(data.year, data.month);

  /// Os dois limites da janela são construídos **em UTC**, e não convertidos do
  /// horário local.
  ///
  /// As datas de atividade são gravadas como meia-noite UTC do dia escolhido
  /// (veja `_meiaNoiteUtc` em `ServicesTratoCultural`). Um
  /// `DateTime(2026, 3, 1).toUtc()` em Brasília vira `2026-03-01T03:00Z` e
  /// deixaria de fora justamente a atividade do dia 1º, que está gravada em
  /// `2026-03-01T00:00Z`.
  DateTime _primeiroInstanteDoMes(DateTime mes) =>
      DateTime.utc(mes.year, mes.month);

  /// O backend compara com `lte`, então o teto é o último instante do mês, não
  /// o primeiro dia do seguinte — senão uma atividade do dia 1º do mês que vem
  /// entraria no mês atual. O dia 0 do mês seguinte é o último dia deste, e o
  /// Dart normaliza o mês 13 para janeiro do ano seguinte sozinho.
  DateTime _ultimoInstanteDoMes(DateTime mes) =>
      DateTime.utc(mes.year, mes.month + 1, 0, 23, 59, 59, 999);
}
