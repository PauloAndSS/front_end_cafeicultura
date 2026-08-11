import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_responsaveis_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';

/// Formulário de cadastro de uma atividade agrícola.
///
/// [CarregarInsumosMixin] fica de fora de propósito: colheita e secagem
/// provavelmente não lançam insumo, e um mixin obrigatório dispararia
/// `GET /insumos` em toda tela de atividade. Quem usa insumo declara no `with`
/// da subclasse.
abstract class CadastrarAtividadeViewModel extends ChangeNotifier
    with DescarteSeguroMixin, CarregarResponsaveisMixin, CarregarTalhoesMixin {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCarregandoDados = false;
  bool get isCarregandoDados => _isCarregandoDados;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  /// 'um trato cultural' — completa a mensagem de "nenhuma propriedade".
  @protected
  String get atividadeIndefinida;

  /// Carrega o que o formulário precisa antes de aceitar entrada: os talhões
  /// (comum a todas) e o que só o tipo concreto conhece.
  Future<void> init(PropriedadesUsuarioViewModel propriedadesViewModel) async {
    final idPropriedade = propriedadesViewModel.idPropriedadeSelecionada;

    if (idPropriedade == null) {
      _mensagemErro =
          'Nenhuma propriedade selecionada. Cadastre uma propriedade antes de lançar $atividadeIndefinida.';
      notificarComSeguranca();
      return;
    }

    _isCarregandoDados = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      await carregarTalhoes(idPropriedade);

      // O mixin não lança: o erro dele chega por aqui.
      _mensagemErro = mensagemErroTalhoes;

      await carregarDadosEspecificos(idPropriedade);
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
    } catch (e) {
      _mensagemErro =
          'Ocorreu um erro interno ao carregar os dados do formulário. Tente novamente mais tarde.';
    } finally {
      _isCarregandoDados = false;
      notificarComSeguranca();
    }
  }

  /// Gancho para o que só o tipo concreto precisa — o catálogo de tipos de
  /// trato, por exemplo. Pode lançar [ApiException]: o [init] trata.
  @protected
  Future<void> carregarDadosEspecificos(int idPropriedade) async {}

  /// Coreografia do POST.
  ///
  /// A chamada vem injetada porque o payload de cadastro de cada atividade é
  /// diferente e a camada de service não foi generalizada — o contrato do
  /// backend das demais atividades ainda não existe.
  @protected
  Future<bool> executarCadastro({
    required Future<bool> Function() chamada,
    required String erroInterno,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      return await chamada();
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = '$erroInterno Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notificarComSeguranca();
    }
  }
}
