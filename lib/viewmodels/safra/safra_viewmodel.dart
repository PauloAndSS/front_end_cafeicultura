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

  bool get isLoading => _isLoading;
  bool get isLoadingRelatorio => _isLoadingRelatorio;
  String? get mensagemErro => _mensagemErro;
  List<Safra> get safras => _safras;
  Safra? get safraSelecionada => _safraSelecionada;
  List<SafraEvento> get relatorio => _relatorio;
  int? get propriedadeIdAtual => _propriedadeIdAtual;
  bool get dadosCarregados => _dadosCarregados;

  Future<void> carregarDadosDaPropriedade(int idPropriedade) async {
    if (_propriedadeIdAtual == idPropriedade && _dadosCarregados) {
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

        if (_safras.isNotEmpty) {
          _safraSelecionada = _safras.first;
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

  Future<void> _refreshSafrasAfterMutation(int idPropriedade) async {
    try {
      final novasSafras = await _buscarSafrasDaPropriedade(idPropriedade);
      _safras = _ordenarSafras(novasSafras);

      if (novasSafras.isEmpty) {
        _safraSelecionada = null;
        _relatorio = [];
      } else if (_safraSelecionada == null ||
          !novasSafras.any((safra) => safra.id == _safraSelecionada?.id)) {
        _safraSelecionada = _safras.first;
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