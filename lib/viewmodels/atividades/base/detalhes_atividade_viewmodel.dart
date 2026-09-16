import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

typedef ChamadaConfirmar = Future<bool> Function(
  int id, {
  required DateTime dataInicio,
  required DateTime dataFim,
});
typedef ChamadaData = Future<bool> Function(int id, DateTime data);
typedef ChamadaTexto = Future<bool> Function(int id, String texto);
typedef ChamadaIds = Future<bool> Function(int id, List<int> ids);
typedef ChamadaExcluir = Future<bool> Function(int id);

abstract class DetalhesAtividadeViewModel<T extends EventoAgricola>
    extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin, CarregarPessoasMixin {
  DetalhesAtividadeViewModel(this._atividade);

  final _despesaService = ServicesDespesa();

  T _atividade;

  T get atividade => _atividade;

  @protected
  set atividade(T nova) => _atividade = nova;

  bool _houveAlteracao = false;

  bool get houveAlteracao => _houveAlteracao;

  @protected
  ChamadaConfirmar? get chamadaConfirmar => null;

  @protected
  ChamadaData? get chamadaAlterarDataInicio => null;

  @protected
  ChamadaTexto? get chamadaAlterarDescricao => null;

  @protected
  ChamadaIds? get chamadaAlterarResponsaveis => null;

  @protected
  ChamadaExcluir? get chamadaExcluir => null;

  bool get podeConfirmar => chamadaConfirmar != null;
  bool get podeAlterarDataInicio => chamadaAlterarDataInicio != null;
  bool get podeAlterarDescricao => chamadaAlterarDescricao != null;
  bool get podeAlterarResponsaveis => chamadaAlterarResponsaveis != null;

  bool get podeExcluir => chamadaExcluir != null && !_atividade.finalizado;

  bool get podeLancarDespesa => !_atividade.finalizado;

  List<Despesa> get despesas =>
      _atividade.transacoesFinanceiras.whereType<Despesa>().toList();

  @protected
  T copiarComum(
    T atual, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    List<Pessoa>? responsaveis,
    List<TransacaoFinanceira>? transacoesFinanceiras,
  });

  Future<bool> confirmar({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) {
    return executarEdicao(
      chamada: () => chamadaConfirmar!(
        _atividade.id!,
        dataInicio: dataInicio,
        dataFim: dataFim,
      ),
      aplicar: () => _atividade = copiarComum(
        _atividade,
        dataInicio: dataInicio,
        dataFim: dataFim,
      ),
    );
  }

  Future<bool> alterarDataInicio(DateTime dataInicio) {
    return executarEdicao(
      chamada: () => chamadaAlterarDataInicio!(_atividade.id!, dataInicio),
      aplicar: () =>
          _atividade = copiarComum(_atividade, dataInicio: dataInicio),
    );
  }

  Future<bool> alterarDescricao(String descricao) {
    final descricaoLimpa = descricao.trim();

    return executarEdicao(
      chamada: () => chamadaAlterarDescricao!(_atividade.id!, descricaoLimpa),
      aplicar: () =>
          _atividade = copiarComum(_atividade, descricao: descricaoLimpa),
    );
  }

  Future<bool> alterarResponsaveis(List<Pessoa> escolhidos) {
    final ids = escolhidos.map((pessoa) => pessoa.id!).toList();

    return executarEdicao(
      chamada: () => chamadaAlterarResponsaveis!(_atividade.id!, ids),
      aplicar: () =>
          _atividade = copiarComum(_atividade, responsaveis: escolhidos),
    );
  }

  Future<bool> lancarDespesa(Despesa despesa) {
    late Despesa lancada;

    return executarEdicao(
      chamada: () async {
        final criada = await _despesaService.cadastrar(
          despesa.comEvento(_atividade.id!),
        );

        lancada = criada ?? despesa;

        return true;
      },
      aplicar: () => _atividade = copiarComum(
        _atividade,
        transacoesFinanceiras: [..._atividade.transacoesFinanceiras, lancada],
      ),
    );
  }

  Future<bool> excluirDespesa(Despesa despesa) {
    return executarEdicao(
      chamada: () => _despesaService.excluir(despesa.id!),
      aplicar: () => _atividade = copiarComum(
        _atividade,
        transacoesFinanceiras: _atividade.transacoesFinanceiras
            .where((atual) => !identical(atual, despesa))
            .toList(),
      ),
    );
  }

  Future<bool> excluir() {
    return executarEdicao(
      chamada: () => chamadaExcluir!(_atividade.id!),
      aplicar: () {},
    );
  }

  @protected
  Future<bool> executarEdicao({
    required Future<bool> Function() chamada,
    required void Function() aplicar,
  }) {
    return cargaPrincipal.executar(
      chamada: () async {
        final sucesso = await chamada();

        if (sucesso) {
          aplicar();
          _houveAlteracao = true;
        }

        return sucesso;
      },
      aoFalhar: () => false,
    );
  }
}
