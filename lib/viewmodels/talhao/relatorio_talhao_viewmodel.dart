import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Eventos de um talhão dentro de uma safra, para o relatório da tela de
/// detalhes do talhão.
///
/// A safra selecionada aqui é **local de propósito**, e não a do
/// `SafraViewModel` global: aquele é a safra de trabalho do usuário — é dela
/// que o cadastro de trato cultural tira o `idSafra` do que vai ser gravado.
/// Consultar o histórico de 2024 num talhão não pode ter como efeito colateral
/// lançar a próxima atividade em 2024.
class RelatorioTalhaoViewModel extends ChangeNotifier with DescarteSeguroMixin {
  final ServicesSafra _service = ServicesSafra();

  bool _isLoading = false;
  String? _mensagemErro;
  List<EventoAgricola> _eventos = [];
  Safra? _safraSelecionada;

  int? _idPropriedade;
  int? _idTalhao;

  bool get isLoading => _isLoading;
  String? get mensagemErro => _mensagemErro;
  List<EventoAgricola> get eventos => _eventos;
  Safra? get safraSelecionada => _safraSelecionada;

  /// Troca a safra do relatório e recarrega os eventos.
  ///
  /// Guarda propriedade e talhão para que [recarregar] não precise que a View
  /// os informe de novo a cada retentativa.
  Future<void> selecionarSafra(
    Safra safra, {
    required int idPropriedade,
    required int idTalhao,
  }) async {
    final mesmaSafra = _safraSelecionada?.id == safra.id;
    final mesmoEscopo = _idPropriedade == idPropriedade && _idTalhao == idTalhao;

    if (mesmaSafra && mesmoEscopo) {
      return;
    }

    _safraSelecionada = safra;
    _idPropriedade = idPropriedade;
    _idTalhao = idTalhao;
    // Os eventos em tela são da safra anterior e não dizem nada sobre esta.
    _eventos = [];
    notificarComSeguranca();

    await recarregar();
  }

  /// Rebusca os eventos da safra e do talhão já selecionados.
  ///
  /// É o que o botão "Tentar novamente" chama, e também o que a View dispara
  /// ao voltar de uma tela que pode ter alterado um evento.
  Future<void> recarregar() async {
    final idPropriedade = _idPropriedade;
    final idTalhao = _idTalhao;
    final idSafra = _safraSelecionada?.id;

    if (idPropriedade == null || idTalhao == null || idSafra == null) {
      return;
    }

    _isLoading = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      final eventos = await _service.buscarRelatorioDoTalhao(
        idPropriedade: idPropriedade,
        idSafra: idSafra,
        idTalhao: idTalhao,
      );

      if (_respostaAindaVale(idSafra)) _eventos = eventos;
    } on ApiException catch (e) {
      if (_respostaAindaVale(idSafra)) _mensagemErro = e.mensagem;
    } catch (e) {
      if (_respostaAindaVale(idSafra)) {
        _mensagemErro = 'Ocorreu um erro interno ao carregar o relatório do talhão. Tente novamente mais tarde.';
      }
      debugPrint('Erro ao carregar relatório do talhão: $e');
    } finally {
      if (_respostaAindaVale(idSafra)) {
        _isLoading = false;
        notificarComSeguranca();
      }
    }
  }

  /// Descarta respostas de uma safra que já não é a selecionada.
  ///
  /// Alternar rápido entre duas safras no dropdown dispara duas requisições, e
  /// a primeira pode voltar depois da segunda — sem esta guarda, o relatório
  /// da safra A se instalaria sob o rótulo da safra B. É a mesma proteção que
  /// `ListaAtividadesPaginadaViewModel` faz com seu contador de geração.
  bool _respostaAindaVale(int idSafra) => _safraSelecionada?.id == idSafra;
}
