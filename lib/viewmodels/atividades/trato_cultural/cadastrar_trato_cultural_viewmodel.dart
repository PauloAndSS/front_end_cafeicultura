import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/dados_formulario_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/tipo_trato.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo_utilizado.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/cadastrar_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_insumos_mixin.dart';

class CadastrarTratoCulturalViewModel extends CadastrarAtividadeViewModel
    with CarregarInsumosMixin {
  /// Provisório: não existe seleção de safra no app. Fica aqui, e não no model,
  /// para que a classe base de todo evento não carregue um dado de produção
  /// chumbado — quando a seleção existir, é este ponto que muda.
  static const int idSafraProvisoria = 2;

  final _tratoService = ServicesTratoCultural();

  List<TipoTrato> _tiposTrato = [];
  List<TipoTrato> get tiposTrato => _tiposTrato;

  @override
  String get atividadeIndefinida => 'um trato cultural';

  /// O catálogo de tipos é o que distingue este formulário dos demais.
  @override
  Future<void> carregarDadosEspecificos(int idPropriedade) async {
    _tiposTrato = await _tratoService.buscarTiposTrato();
  }

  Future<bool> submeterFormulario({
    required DadosFormularioAtividade dados,
    required TipoTrato tipoTrato,
    required List<InsumoUtilizado> insumosUtilizados,
  }) {
    return executarCadastro(
      chamada: () {
        final trato = TratoCultural(
          idTalhao: dados.idTalhao,
          tipoTrato: tipoTrato,
          dataInicio: dados.dataInicio,
          dataFim: dados.dataFim,
          descricao: dados.descricao?.trim(),
          idSafra: idSafraProvisoria,
          responsaveis: dados.responsaveis,
          insumosUtilizados: insumosUtilizados,
        );

        return _tratoService.cadastrar(trato);
      },
      erroInterno: 'Ocorreu um erro interno ao cadastrar trato cultural.',
    );
  }
}
