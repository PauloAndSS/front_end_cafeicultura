import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/carregar_insumos_mixin.dart';

class DetalhesTratoCulturalViewModel
    extends DetalhesAtividadeViewModel<TratoCultural>
    with CarregarInsumosMixin {
  DetalhesTratoCulturalViewModel(super.trato);

  final _tratoService = ServicesTratoCultural();

  TratoCultural get trato => atividade;

  @override
  ChamadaConfirmar? get chamadaConfirmar => _tratoService.confirmar;

  @override
  ChamadaData? get chamadaAlterarDataInicio => _tratoService.alterarDataInicio;

  @override
  ChamadaTexto? get chamadaAlterarDescricao => _tratoService.alterarDescricao;

  @override
  ChamadaIds? get chamadaAlterarResponsaveis =>
      _tratoService.alterarResponsaveis;

  @override
  ChamadaExcluir? get chamadaExcluir => _tratoService.excluir;

  @override
  TratoCultural copiarComum(
    TratoCultural atual, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    List<Pessoa>? responsaveis,
    List<TransacaoFinanceira>? transacoesFinanceiras,
  }) {
    return atual.copyWith(
      dataInicio: dataInicio,
      dataFim: dataFim,
      descricao: descricao,
      responsaveis: responsaveis,
      transacoesFinanceiras: transacoesFinanceiras,
    );
  }

  Future<bool> removerInsumo(InsumoUtilizado insumo) => _removerInsumos([insumo]);

  Future<bool> alterarInsumos(List<InsumoUtilizado> escolhidos) async {
    final diferenca = DiferencaDeInsumos.entre(
      atuais: trato.insumosUtilizados,
      escolhidos: escolhidos,
    );

    if (diferenca.semMudancas) return true;

    if (diferenca.removidos.isNotEmpty) {
      final removeu = await _removerInsumos(diferenca.removidos);
      if (!removeu) return false;
    }

    if (diferenca.inseridos.isEmpty) return true;

    return _inserirInsumos(diferenca.inseridos);
  }

  Future<bool> _removerInsumos(List<InsumoUtilizado> removidos) {
    final ids = removidos.map((insumo) => insumo.idInsumo).toSet();

    return executarEdicao(
      chamada: () => _tratoService.removerInsumos(atividade.id!, ids.toList()),
      aplicar: () => _atualizarInsumos(
        trato.insumosUtilizados
            .where((atual) => !ids.contains(atual.idInsumo))
            .toList(),
      ),
    );
  }

  Future<bool> _inserirInsumos(List<InsumoUtilizado> inseridos) {
    return executarEdicao(
      chamada: () => _tratoService.inserirInsumos(atividade.id!, inseridos),
      aplicar: () =>
          _atualizarInsumos([...trato.insumosUtilizados, ...inseridos]),
    );
  }

  void _atualizarInsumos(List<InsumoUtilizado> insumos) {
    atividade = atividade.copyWith(insumosUtilizados: insumos);
    marcarInsumosDesatualizados();
  }
}
