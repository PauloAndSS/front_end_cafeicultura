import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_responsaveis_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';

abstract class CadastrarAtividadeViewModel extends ChangeNotifier
    with
        NotificaSeVivoMixin,
        EstadoDeCarregamentoMixin,
        CarregarResponsaveisMixin,
        CarregarTalhoesMixin {
  late final EstadoDeCarga _cargaDados = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  bool get isCarregandoDados => _cargaDados.isLoading;

  @protected
  String get atividadeIndefinida;

  Future<void> init(PropriedadesUsuarioViewModel propriedadesViewModel) async {
    final idPropriedade = propriedadesViewModel.idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mensagemErro =
          'Nenhuma propriedade selecionada. Cadastre uma propriedade antes de lançar $atividadeIndefinida.';
      notificarSeVivo();
      return;
    }

    await _cargaDados.executar(
      chamada: () async {
        await carregarTalhoes(idPropriedade);

        mensagemErro = mensagemErroTalhoes;

        await carregarDadosEspecificos(idPropriedade);
      },
      aoFalhar: () {},
    );
  }

  @protected
  Future<void> carregarDadosEspecificos(int idPropriedade) async {}

  @protected
  Future<bool> executarCadastro({
    required Future<bool> Function() chamada,
  }) {
    return cargaPrincipal.executar(
      chamada: chamada,
      aoFalhar: () => false,
    );
  }
}
