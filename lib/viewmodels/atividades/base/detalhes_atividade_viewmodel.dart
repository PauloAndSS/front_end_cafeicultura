import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_evento.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_responsaveis_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

typedef ChamadaConfirmar = Future<bool> Function(
  int id, {
  required DateTime dataInicio,
  required DateTime dataFim,
});
typedef ChamadaData = Future<bool> Function(int id, DateTime data);
typedef ChamadaTexto = Future<bool> Function(int id, String texto);
typedef ChamadaIds = Future<bool> Function(int id, List<int> ids);

/// Detalhe de uma atividade agrícola, com edição campo a campo.
///
/// Cada PATCH entra como **tear-off do service da subclasse**, não como método
/// abstrato obrigatório. O motivo: um método abstrato assumiria que toda
/// atividade futura tem os três endpoints de edição. Se uma delas for evento
/// pontual sem `dataFim`, ou não tiver rota de descrição, a subclasse seria
/// obrigada a um `throw UnimplementedError()` — erro em runtime onde deveria
/// ser simplesmente ausência de botão. Com o getter anulável, `null` já é a
/// flag de capacidade ([podeConfirmar] e companhia) que a View consulta.
abstract class DetalhesAtividadeViewModel<T extends EventoAgricola>
    extends ChangeNotifier with DescarteSeguroMixin, CarregarResponsaveisMixin {
  DetalhesAtividadeViewModel(this._atividade);

  T _atividade;

  /// Cópia local, atualizada a cada PATCH bem-sucedido.
  T get atividade => _atividade;

  /// Para as ações específicas da subclasse refletirem o PATCH delas.
  @protected
  set atividade(T nova) => _atividade = nova;

  bool _houveAlteracao = false;

  /// Devolvido no pop para a listagem decidir se recarrega.
  bool get houveAlteracao => _houveAlteracao;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

  /// 'o trato cultural' — entra nas mensagens de erro interno.
  @protected
  String get rotuloAtividade;

  // --- injeção da camada HTTP ---------------------------------------------

  @protected
  ChamadaConfirmar? get chamadaConfirmar => null;

  @protected
  ChamadaData? get chamadaAlterarDataInicio => null;

  @protected
  ChamadaTexto? get chamadaAlterarDescricao => null;

  @protected
  ChamadaIds? get chamadaAlterarResponsaveis => null;

  bool get podeConfirmar => chamadaConfirmar != null;
  bool get podeAlterarDataInicio => chamadaAlterarDataInicio != null;
  bool get podeAlterarDescricao => chamadaAlterarDescricao != null;
  bool get podeAlterarResponsaveis => chamadaAlterarResponsaveis != null;

  /// Excluir é a exceção à injeção acima: a rota é a mesma para todo módulo
  /// (`DELETE /eventos/{id}`), então um getter anulável por subclasse seria
  /// cada subclasse devolvendo o tear-off do mesmo método.
  final _eventoService = ServicesEvento();

  /// Agendada e em andamento saem; finalizada é histórico e fica.
  ///
  /// Só o estado é conferido aqui. Se a atividade pode mesmo ser apagada —
  /// safra fechada, vínculo com despesa, o que for — quem responde é o backend,
  /// e a recusa dele vira [mensagemErro].
  bool get podeExcluir => !_atividade.finalizado;

  /// Cópia com os campos **comuns** trocados, preservando os específicos.
  ///
  /// Dart não herda `copyWith`: ele precisa nomear todos os campos do construtor
  /// concreto. Em vez de forçar um `copiarComum` no model — que existiria só
  /// para servir este ViewModel e ainda obrigaria a um `as T` aqui —, o gancho
  /// fica deste lado e a subclasse delega ao `copyWith` dela.
  @protected
  T copiarComum(
    T atual, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? descricao,
    List<Pessoa>? responsaveis,
  });

  // --- ações ---------------------------------------------------------------

  /// Fecha a atividade na [dataFim], com a [dataInicio] eventualmente corrigida
  /// na tela de confirmação.
  ///
  /// As duas datas vão para o endpoint mesmo quando o início não mudou — é ele
  /// quem valida o par.
  Future<bool> confirmar({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) {
    return executar(
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
      erroInterno: 'Ocorreu um erro interno ao confirmar $rotuloAtividade.',
    );
  }

  /// Corrige ou reagenda o início de uma atividade ainda aberta.
  ///
  /// Jogar a data para frente rebaixa a atividade a "Agendada" — o status é
  /// derivado das datas, então a View se reconfigura sozinha no rebuild.
  Future<bool> alterarDataInicio(DateTime dataInicio) {
    return executar(
      chamada: () => chamadaAlterarDataInicio!(_atividade.id!, dataInicio),
      aplicar: () =>
          _atividade = copiarComum(_atividade, dataInicio: dataInicio),
      erroInterno: 'Ocorreu um erro interno ao alterar a data de início.',
    );
  }

  Future<bool> alterarDescricao(String descricao) {
    final descricaoLimpa = descricao.trim();

    return executar(
      chamada: () => chamadaAlterarDescricao!(_atividade.id!, descricaoLimpa),
      aplicar: () =>
          _atividade = copiarComum(_atividade, descricao: descricaoLimpa),
      erroInterno: 'Ocorreu um erro interno ao alterar a descrição.',
    );
  }

  /// Recebe o conjunto final de responsáveis — o endpoint substitui a lista,
  /// então quem não vier aqui é desvinculado no backend.
  ///
  /// Precisa dos nomes, e não só dos ids, porque o PATCH não devolve a
  /// atividade atualizada: é daqui que sai o que a tela reexibe.
  Future<bool> alterarResponsaveis(List<Pessoa> escolhidos) {
    final ids = escolhidos.map((pessoa) => pessoa.id!).toList();

    return executar(
      chamada: () => chamadaAlterarResponsaveis!(_atividade.id!, ids),
      aplicar: () =>
          _atividade = copiarComum(_atividade, responsaveis: escolhidos),
      erroInterno: 'Ocorreu um erro interno ao alterar os responsáveis.',
    );
  }

  /// Apaga a atividade. Em caso de sucesso a tela **precisa** fechar: o objeto
  /// que ela desenha deixou de existir no servidor.
  Future<bool> excluir() {
    return executar(
      chamada: () => _eventoService.excluir(_atividade.id!),
      // Nada a refletir na cópia local — a atividade inteira sai de cena. O que
      // interessa deste caminho é `houveAlteracao`, que `executar` liga sozinho
      // e é o sinal que faz a listagem e o calendário recarregarem.
      aplicar: () {},
      erroInterno: 'Ocorreu um erro interno ao excluir $rotuloAtividade.',
    );
  }

  /// Coreografia comum a toda edição: bloqueia a tela, chama o PATCH e só
  /// depois do 200 reflete a mudança na cópia local.
  ///
  /// `@protected` para as ações específicas da subclasse reaproveitarem.
  @protected
  Future<bool> executar({
    required Future<bool> Function() chamada,
    required void Function() aplicar,
    required String erroInterno,
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notificarComSeguranca();

    try {
      final sucesso = await chamada();

      if (sucesso) {
        aplicar();
        _houveAlteracao = true;
      }

      return sucesso;
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
