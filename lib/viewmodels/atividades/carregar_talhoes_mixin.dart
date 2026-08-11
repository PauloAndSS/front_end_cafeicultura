import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_talhao.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Talhões da propriedade, com a paginação já resolvida.
///
/// Duas telas precisam disso por motivos diferentes: o formulário de cadastro
/// escolhe em qual talhão a atividade acontece, e a listagem traduz o
/// `idTalhao` do payload para um nome exibível. Antes deste mixin o mesmo laço
/// de paginação existia nos dois ViewModels, com projeções diferentes.
///
/// Guarda **todos** os talhões, inclusive os encerrados: uma atividade
/// finalizada pode apontar para um talhão que já fechou e o card ainda precisa
/// do nome. Quem cadastra usa [talhoesAtivos].
///
/// Nunca lança — o erro fica em [mensagemErroTalhoes], como nos demais
/// carregadores. Nome de talhão ausente degrada para `Talhão #id`, não é motivo
/// para derrubar a tela inteira.
mixin CarregarTalhoesMixin on DescarteSeguroMixin {
  static const int _limitePorPagina = 10;

  static const int _maxPaginas = 50;

  final _talhaoService = ServicesTalhao();

  final List<Talhao> _talhoes = [];
  List<Talhao> get talhoes => List.unmodifiable(_talhoes);

  /// Só os que ainda estão abertos e têm id — os que podem receber atividade.
  List<Talhao> get talhoesAtivos => _talhoes
      .where((talhao) => talhao.dataFim == null)
      .where((talhao) => talhao.id != null)
      .toList();

  bool _talhoesCarregados = false;
  bool get talhoesCarregados => _talhoesCarregados;

  bool _isCarregandoTalhoes = false;
  bool get isCarregandoTalhoes => _isCarregandoTalhoes;

  String? _mensagemErroTalhoes;
  String? get mensagemErroTalhoes => _mensagemErroTalhoes;

  String nomeDoTalhao(int idTalhao) {
    for (final talhao in _talhoes) {
      if (talhao.id == idTalhao) return talhao.nomeExibicao;
    }
    return 'Talhão #$idTalhao';
  }

  Future<void> carregarTalhoes(int idPropriedade) async {
    if (_isCarregandoTalhoes) return;

    _isCarregandoTalhoes = true;
    _mensagemErroTalhoes = null;
    notificarComSeguranca();

    final carregados = <Talhao>[];
    var pagina = 1;

    try {
      while (pagina <= _maxPaginas) {
        final lote = await _talhaoService.buscarTodosTalhoesPorPropriedade(
          idPropriedade,
          pagina: pagina,
          limite: _limitePorPagina,
        );

        carregados.addAll(lote);

        if (lote.length < _limitePorPagina) break;
        pagina++;
      }

      _talhoes
        ..clear()
        ..addAll(carregados);
      _talhoesCarregados = true;
    } catch (e) {
      debugPrint('Erro ao carregar talhões da propriedade: $e');
      _mensagemErroTalhoes =
          'Ocorreu um erro interno ao carregar os talhões. Tente novamente mais tarde.';
    } finally {
      _isCarregandoTalhoes = false;
      notificarComSeguranca();
    }
  }
}
