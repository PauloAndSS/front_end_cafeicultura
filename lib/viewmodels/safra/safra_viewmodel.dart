import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';

class SafraViewModel extends ChangeNotifier {
  final ServicesSafra _service = ServicesSafra();

  bool _isLoading = false;
  bool _isLoadingRelatorio = false;
  String? _mensagemErro;
  List<Safra> _safras = [];
  Safra? _safraSelecionada;
  List<EventoAgricola> _relatorio = [];
  int? _propriedadeIdAtual;
  bool _dadosCarregados = false;

  /// Cache em memória (dura enquanto o app estiver aberto/a sessão do
  /// usuário estiver ativa) das safras já carregadas por propriedade.
  /// Evita bater na API de novo toda vez que o usuário volta para a tela
  /// de safras ou alterna entre propriedades já visitadas na sessão.
  final Map<int, List<Safra>> _cacheSafrasPorPropriedade = {};

  /// Guarda também qual era a safra selecionada em cada propriedade, para
  /// restaurar a seleção certa ao voltar para uma propriedade já visitada.
  final Map<int, int?> _cacheSafraSelecionadaPorPropriedade = {};

  bool get isLoading => _isLoading;
  bool get isLoadingRelatorio => _isLoadingRelatorio;
  String? get mensagemErro => _mensagemErro;
  List<Safra> get safras => _safras;
  Safra? get safraSelecionada => _safraSelecionada;
  List<EventoAgricola> get relatorio => _relatorio;
  int? get propriedadeIdAtual => _propriedadeIdAtual;
  bool get dadosCarregados => _dadosCarregados;

  /// Safras em que ainda se pode lançar atividade.
  ///
  /// Separado de [safras] de propósito: aquela lista é de navegação — a tela
  /// de safras precisa mostrar as encerradas para consultar e reativar. Esta é
  /// a de escrita, e o cadastro de atividade só enxerga esta.
  List<Safra> get safrasAtivas =>
      _safras.where((safra) => safra.ativa).toList();

  /// Safra de [id] entre as da propriedade carregada, ou `null`.
  ///
  /// Traduz o `idSafra` cru que o evento carrega em algo exibível, sem obrigar
  /// cada tela a varrer a lista por conta própria. Busca em todas, e não só
  /// nas ativas: uma atividade antiga pertence legitimamente a uma safra já
  /// encerrada, e é justamente ela que o card de detalhes precisa nomear.
  Safra? safraPorId(int? id) {
    if (id == null) return null;

    for (final safra in _safras) {
      if (safra.id == id) return safra;
    }

    return null;
  }

  /// Carrega as safras da propriedade informada.
  ///
  /// Por padrão, se essa propriedade já tiver sido carregada nesta sessão
  /// (o app segue aberto, mesmo que o usuário tenha navegado para outra
  /// tela e voltado), os dados são restaurados direto do cache em memória,
  /// sem nova chamada à API. Use [forcarAtualizacao] para ignorar o cache
  /// (ex: pull-to-refresh) e buscar novamente na API.
  Future<void> carregarDadosDaPropriedade(
    int idPropriedade, {
    bool forcarAtualizacao = false,
  }) async {
    // Já é a propriedade atual e os dados já estão carregados: nada a fazer.
    if (!forcarAtualizacao && _propriedadeIdAtual == idPropriedade && _dadosCarregados) {
      return;
    }

    // Propriedade já visitada nesta sessão: restaura do cache em memória
    // em vez de ir buscar tudo de novo na API.
    if (!forcarAtualizacao && _cacheSafrasPorPropriedade.containsKey(idPropriedade)) {
      _propriedadeIdAtual = idPropriedade;
      _mensagemErro = null;
      _restaurarSafrasDoCache(idPropriedade);
      _dadosCarregados = true;
      notifyListeners();

      // Garante que o relatório da safra selecionada esteja carregado
      // (o relatório em si não é persistido no cache de sessão).
      if (_safraSelecionada?.id != null) {
        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      }
      return;
    }

    _propriedadeIdAtual = idPropriedade;
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final safrasCarregadas = _ordenarSafras(await _service.buscarPorPropriedade(idPropriedade));

      if (safrasCarregadas.isNotEmpty) {
        _safras = safrasCarregadas;
        _salvarSafrasNoCache(idPropriedade, _safras);

        _safraSelecionada = _safras.first;
        _cacheSafraSelecionadaPorPropriedade[idPropriedade] = _safraSelecionada!.id;
        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      } else {
        _safras = [];
        _safraSelecionada = null;
        _relatorio = [];
        _salvarSafrasNoCache(idPropriedade, _safras);
      }
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro de conexão ao carregar as safras.';
      debugPrint('Erro ao carregar safras: $e');
    } finally {
      _isLoading = false;
      _dadosCarregados = true;
      notifyListeners();
    }
  }

  /// Restaura, a partir do cache de sessão, a lista de safras e a safra
  /// selecionada de uma propriedade já visitada anteriormente.
  void _restaurarSafrasDoCache(int idPropriedade) {
    _safras = List<Safra>.from(_cacheSafrasPorPropriedade[idPropriedade] ?? const []);

    final idSelecionadaCache = _cacheSafraSelecionadaPorPropriedade[idPropriedade];
    Safra? safraRestaurada;
    if (idSelecionadaCache != null) {
      for (final safra in _safras) {
        if (safra.id == idSelecionadaCache) {
          safraRestaurada = safra;
          break;
        }
      }
    }
    _safraSelecionada = safraRestaurada ?? (_safras.isNotEmpty ? _safras.first : null);
  }

  void _salvarSafrasNoCache(int idPropriedade, List<Safra> safras) {
    _cacheSafrasPorPropriedade[idPropriedade] = List<Safra>.from(safras);
  }

  /// Limpa o cache de sessão de todas as propriedades (ex: no logout do
  /// usuário) ou apenas de uma propriedade específica, se [idPropriedade]
  /// for informado.
  void limparCacheSessao({int? idPropriedade}) {
    if (idPropriedade != null) {
      _cacheSafrasPorPropriedade.remove(idPropriedade);
      _cacheSafraSelecionadaPorPropriedade.remove(idPropriedade);
      if (_propriedadeIdAtual == idPropriedade) {
        _dadosCarregados = false;
      }
    } else {
      _cacheSafrasPorPropriedade.clear();
      _cacheSafraSelecionadaPorPropriedade.clear();
      _dadosCarregados = false;
    }
    notifyListeners();
  }

  Future<void> selecionarSafra(Safra safra) async {
    if (_safraSelecionada?.id == safra.id) {
      return;
    }

    _safraSelecionada = safra;
    _relatorio = [];
    notifyListeners();

    if (_propriedadeIdAtual == null || safra.id == null) {
      return;
    }

    _cacheSafraSelecionadaPorPropriedade[_propriedadeIdAtual!] = safra.id;

    await carregarRelatorioDaSafra(
      idPropriedade: _propriedadeIdAtual!,
      idSafra: safra.id!,
    );
  }

  Future<void> carregarRelatorioDaSafra({
    required int idPropriedade,
    required int idSafra,
  }) async {
    _isLoadingRelatorio = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _relatorio = await _service.buscarRelatorio(
        idPropriedade: idPropriedade,
        idSafra: idSafra,
      );
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro ao carregar o relatório da safra.';
      debugPrint('Erro ao carregar relatório da safra: $e');
    } finally {
      _isLoadingRelatorio = false;
      notifyListeners();
    }
  }

  Future<bool> criarSafra({
    required int idPropriedade,
    DateTime? dataInicio,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _service.cadastrar(idPropriedade: idPropriedade, dataInicio: dataInicio);
      await _refreshSafrasAfterMutation(idPropriedade);
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro ao cadastrar a safra.';
      debugPrint('Erro ao cadastrar safra: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> encerrarSafra({
    required int idPropriedade,
    required int idSafra,
    DateTime? dataFim,
  }) async {
    if (idSafra <= 0) {
      _mensagemErro = 'Selecione uma safra válida para encerrar.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _service.encerrar(idSafra, dataFim: dataFim);
      await _refreshSafrasAfterMutation(idPropriedade);
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro ao encerrar a safra.';
      debugPrint('Erro ao encerrar safra: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> reativarSafra({
    required int idPropriedade,
    required int idSafra,
  }) async {
    if (idSafra <= 0) {
      _mensagemErro = 'Selecione uma safra válida para reativar.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _service.reativar(idSafra);
      await _refreshSafrasAfterMutation(idPropriedade);
      return true;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro = 'Erro ao reativar a safra.';
      debugPrint('Erro ao reativar safra: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<void> _refreshSafrasAfterMutation(int idPropriedade) async {
    try {
      final novasSafras = _ordenarSafras(await _service.buscarPorPropriedade(idPropriedade));
      _safras = novasSafras;
      // Mutação (criar/encerrar/reativar) sempre atualiza o cache de sessão
      // dessa propriedade, já que os dados no servidor mudaram.
      _salvarSafrasNoCache(idPropriedade, _safras);

      if (novasSafras.isEmpty) {
        _safraSelecionada = null;
        _relatorio = [];
        _cacheSafraSelecionadaPorPropriedade.remove(idPropriedade);
      } else if (_safraSelecionada == null ||
          !novasSafras.any((safra) => safra.id == _safraSelecionada?.id)) {
        _safraSelecionada = _safras.first;
        _cacheSafraSelecionadaPorPropriedade[idPropriedade] = _safraSelecionada!.id;
        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: _safraSelecionada!.id!,
        );
      } else if (_safraSelecionada != null) {
        final safraAtualizada = novasSafras.firstWhere(
          (safra) => safra.id == _safraSelecionada!.id,
          orElse: () => _safraSelecionada!,
        );
        _safraSelecionada = safraAtualizada;
        _cacheSafraSelecionadaPorPropriedade[idPropriedade] = safraAtualizada.id;
        await carregarRelatorioDaSafra(
          idPropriedade: idPropriedade,
          idSafra: safraAtualizada.id!,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar a lista de safras após mutação: $e');
    }
  }

  /// Ordena as safras em ordem cronológica decrescente de início (a mais
  /// recente primeiro). Fica no viewmodel (não no service) porque é uma
  /// questão de apresentação, não de acesso a dados — `ServicesSafra`
  /// só busca e devolve os dados como a API os enviou, seguindo o mesmo
  /// padrão dos outros services do projeto (ex: `ServicesPropriedade`).
  List<Safra> _ordenarSafras(List<Safra> safras) {
    final copia = List<Safra>.from(safras);
    copia.sort((a, b) {
      final dataA = a.dataInicio ?? a.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB = b.dataInicio ?? b.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final comparacaoData = dataB.compareTo(dataA);
      if (comparacaoData != 0) {
        return comparacaoData;
      }
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return copia;
  }
}