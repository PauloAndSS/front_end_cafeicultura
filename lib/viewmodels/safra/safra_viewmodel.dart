import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';

class _SafraApiService extends BaseService {}

class SafraViewModel extends ChangeNotifier {
  final _SafraApiService _service = _SafraApiService();

  bool _isLoading = false;
  bool _isLoadingRelatorio = false;
  String? _mensagemErro;
  List<Safra> _safras = [];
  Safra? _safraSelecionada;
  List<SafraEvento> _relatorio = [];
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
  List<SafraEvento> get relatorio => _relatorio;
  int? get propriedadeIdAtual => _propriedadeIdAtual;
  bool get dadosCarregados => _dadosCarregados;

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
      final safrasCarregadas = await _buscarSafrasDaPropriedade(idPropriedade);

      if (safrasCarregadas.isNotEmpty) {
        _safras = _ordenarSafras(safrasCarregadas);
        _salvarSafrasNoCache(idPropriedade, _safras);

        if (_safras.isNotEmpty) {
          _safraSelecionada = _safras.first;
          _cacheSafraSelecionadaPorPropriedade[idPropriedade] = _safraSelecionada!.id;
          await carregarRelatorioDaSafra(
            idPropriedade: idPropriedade,
            idSafra: _safraSelecionada!.id!,
          );
        } else {
          _safraSelecionada = null;
          _relatorio = [];
        }
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
      final response = await http.get(
        Uri.parse(
          '${_service.baseUrl}/safras/propriedade/$idPropriedade/safra/$idSafra/eventos',
        ),
        headers: _service.defaultHeaders,
      );

      debugPrint('GET relatório status=${response.statusCode} body=${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _relatorio = _parseRelatorio(response.body);
      } else {
        final mensagemDeErro = _extractErrorMessage(response.body);

        if (_isMensagemSemRegistro(mensagemDeErro)) {
          // Não é um erro de fato: apenas não há eventos cadastrados
          // ainda para essa safra. Tratamos como relatório vazio.
          _relatorio = [];
        } else {
          throw ApiException(mensagemDeErro);
        }
      }
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
      final payload = {
        'idPropriedade': idPropriedade,
        'dataInicio': (dataInicio ?? DateTime.now()).toUtc().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${_service.baseUrl}/safras/'),
        headers: _service.defaultHeaders,
        body: jsonEncode(payload),
      );

      debugPrint('POST safra status=${response.statusCode} body=${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _refreshSafrasAfterMutation(idPropriedade);
        return true;
      }

      throw ApiException(_extractErrorMessage(response.body));
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
      final response = await http.patch(
        Uri.parse('${_service.baseUrl}/safras/$idSafra/finalizar'),
        headers: _service.defaultHeaders,
        body: jsonEncode({
          'dataFim': (dataFim ?? DateTime.now()).toUtc().toIso8601String(),
        }),
      );

      debugPrint('PATCH safra status=${response.statusCode} body=${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _refreshSafrasAfterMutation(idPropriedade);
        return true;
      }

      throw ApiException(_extractErrorMessage(response.body));
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
      final response = await http.patch(
        Uri.parse('${_service.baseUrl}/safras/$idSafra/reativar'),
        headers: _service.defaultHeaders,
      );

      debugPrint('PATCH reativar safra status=${response.statusCode} body=${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _refreshSafrasAfterMutation(idPropriedade);
        return true;
      }

      throw ApiException(_extractErrorMessage(response.body));
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
      final novasSafras = await _buscarSafrasDaPropriedade(idPropriedade);
      _safras = _ordenarSafras(novasSafras);
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

  Future<List<Safra>> _buscarSafrasDaPropriedade(int idPropriedade) async {
    final endpoints = [
      Uri.parse('${_service.baseUrl}/safras/propriedade/${idPropriedade}/safras/todas'),
    ];

    final listasEncontradas = <List<Safra>>[];

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(endpoint, headers: _service.defaultHeaders);

        debugPrint('GET safras status=${response.statusCode} body=${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final lista = _parseSafras(response.body);
          if (lista.isNotEmpty) {
            listasEncontradas.add(lista);
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar safras em $endpoint: $e');
      }
    }

    if (listasEncontradas.isEmpty) {
      return [];
    }

    final merged = <int, Safra>{};
    for (final lista in listasEncontradas) {
      for (final safra in lista) {
        if (safra.id != null) {
          merged[safra.id!] = safra;
        }
      }
    }

    if (merged.isNotEmpty) {
      return _ordenarSafras(merged.values.toList());
    }

    return _ordenarSafras(listasEncontradas.first);
  }

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

  List<Safra> _parseSafras(String body) {
    if (body.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded.whereType<Map>().map((item) {
        return Safra.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    if (decoded is Map<String, dynamic>) {
      final list = _extractList(decoded);
      return list.map((item) {
        if (item is Map<String, dynamic>) {
          return Safra.fromJson(item);
        }

        if (item is Map) {
          return Safra.fromJson(Map<String, dynamic>.from(item));
        }

        return Safra();
      }).toList();
    }

    return [];
  }

  List<SafraEvento> _parseRelatorio(String body) {
    if (body.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded.whereType<Map>().map((item) {
        return SafraEvento.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    if (decoded is Map<String, dynamic>) {
      final list = _extractList(decoded);
      return list.map((item) {
        if (item is Map<String, dynamic>) {
          return SafraEvento.fromJson(item);
        }

        if (item is Map) {
          return SafraEvento.fromJson(Map<String, dynamic>.from(item));
        }

        return const SafraEvento();
      }).toList();
    }

    return [];
  }

  List<dynamic> _extractList(Map<String, dynamic> payload) {
    final candidates = [
      payload['data'],
      payload['items'],
      payload['result'],
      payload['safras'],
      payload['eventos'],
      payload['events'],
      payload['relatorio'],
      payload['dados'],
      payload['ativas'],
      payload['encerradas'],
      payload['historico'],
      payload['todos'],
      payload['all'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    if (payload['data'] is Map<String, dynamic>) {
      final nested = payload['data'] as Map<String, dynamic>;
      return _extractList(nested);
    }

    return [];
  }

  bool _isMensagemSemRegistro(String mensagem) {
    final normalizada = _removerAcentos(mensagem.toLowerCase());

    final indicaAusencia = normalizada.contains('nao possui') ||
        normalizada.contains('nenhum') ||
        normalizada.contains('sem eventos') ||
        normalizada.contains('sem registro');

    final indicaEventos = normalizada.contains('evento') ||
        normalizada.contains('registrad') ||
        normalizada.contains('exemplo') ||
        normalizada.contains('relatorio');

    return indicaAusencia && indicaEventos;
  }

  String _removerAcentos(String texto) {
    const comAcento = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    var resultado = texto;
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Erro ao buscar os dados da safra.';
      }
    } catch (_) {}

    return 'Erro ao buscar os dados da safra.';
  }
}