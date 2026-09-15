import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_notificacao.dart';
import 'package:frond_end_cafeicultura_mobile/http/websocket/canal_notificacoes.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao_agrupada.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/registro_de_leituras.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/carregar_talhoes_mixin.dart';

export 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao_agrupada.dart';

class SecaoDeNotificacoes {
  final String titulo;
  final List<NotificacaoAgrupada> grupos;

  const SecaoDeNotificacoes(this.titulo, this.grupos);
}

class NotificacoesViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin, CarregarTalhoesMixin {
  late final EstadoDeCarga _cargaAtividades = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  late final EstadoDeCarga _cargaLeitura = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  final _service = ServicesNotificacao();
  final _tratoService = ServicesTratoCultural();
  final _canal = CanalNotificacoes();
  final _leituras = RegistroDeLeituras();

  final Map<int, TratoCultural> _atividadesPorEvento = {};

  List<Notificacao> _notificacoes = [];
  List<NotificacaoAgrupada> _grupos = [];

  StreamSubscription<Notificacao>? _escuta;

  int? _idPropriedadeAtual;
  int? _propriedadeJaTentada;
  int _geracaoDoCacheVista = 0;

  List<NotificacaoAgrupada> get grupos => List.unmodifiable(_grupos);

  List<NotificacaoAgrupada> get _visiveis => _grupos
      .where((grupo) => !estaConfirmada(grupo))
      .where((grupo) => !_lembreteVencido(grupo))
      .toList();

  List<NotificacaoAgrupada> get naoLidas => _visiveis
      .where((grupo) => !grupo.lida || aguardaResposta(grupo))
      .toList();

  List<NotificacaoAgrupada> get lidas => _visiveis
      .where((grupo) => grupo.lida && !aguardaResposta(grupo))
      .toList();

  List<NotificacaoAgrupada> get pendentesDeResposta =>
      naoLidas.where(aguardaResposta).toList();

  List<NotificacaoAgrupada> get naoLidasSemPendencia =>
      naoLidas.where((grupo) => !aguardaResposta(grupo)).toList();

  int get quantidadeNaoLidas => naoLidas.length;

  bool get temNaoLidas => quantidadeNaoLidas > 0;

  bool get temLeituraPendente => naoLidasSemPendencia.isNotEmpty;

  bool get vazio => _visiveis.isEmpty;

  bool get marcandoLeitura => _cargaLeitura.isLoading;

  String? get mensagemErroLeitura => _cargaLeitura.mensagemErro;

  String? _falhaDeLeitura;

  String? consumirFalhaDeLeitura() {
    final falha = _falhaDeLeitura;

    _falhaDeLeitura = null;

    return falha;
  }

  List<SecaoDeNotificacoes> get secoesNaoLidas => _secoes(naoLidas);

  List<SecaoDeNotificacoes> get secoesLidas => _secoes(lidas);

  TratoCultural? atividadeDe(NotificacaoAgrupada grupo) =>
      _atividadesPorEvento[grupo.idEvento];

  bool estaConfirmada(NotificacaoAgrupada grupo) =>
      atividadeDe(grupo)?.finalizado ?? false;

  bool aguardaResposta(NotificacaoAgrupada grupo) =>
      grupo.ehConfirmacao &&
      (grupo.tipoEvento?.temTelaPropria ?? false) &&
      !estaConfirmada(grupo);

  DateTime dataDoEvento(NotificacaoAgrupada grupo) =>
      atividadeDe(grupo)?.dataInicio ?? grupo.dataPrevistaDoEvento;

  HorizonteDaNotificacao _horizonteDe(NotificacaoAgrupada grupo) =>
      HorizonteDaNotificacao.de(dataDoEvento(grupo));

  bool _lembreteVencido(NotificacaoAgrupada grupo) =>
      !grupo.ehConfirmacao &&
      _horizonteDe(grupo) == HorizonteDaNotificacao.vencido;

  Future<void> garantirCarregado(int idPropriedade) {
    if (isLoading || _propriedadeJaTentada == idPropriedade) {
      return Future.value();
    }

    return carregar(idPropriedade);
  }

  Future<void> carregar(int idPropriedade) {
    final trocouPropriedade = _idPropriedadeAtual != idPropriedade;

    if (trocouPropriedade) {
      _atividadesPorEvento.clear();
      _notificacoes = [];
      _grupos = [];
    }

    _idPropriedadeAtual = idPropriedade;
    _propriedadeJaTentada = idPropriedade;

    return cargaPrincipal.executar(
      chamada: () async {
        if (trocouPropriedade || !talhoesCarregados) {
          await carregarTalhoes(idPropriedade);
        }

        _notificacoes = await _service.buscarDaPropriedade(idPropriedade);

        await _leituras.sincronizarCom(idPropriedade, _notificacoes);
        _notificacoes = _leituras.aplicar(_notificacoes);

        _reagrupar();

        _conectar();

        await _carregarAtividades();
      },
      aoFalhar: () {},
    );
  }

  Future<void> recarregar() {
    final idPropriedade = _idPropriedadeAtual;

    if (idPropriedade == null) return Future.value();

    _atividadesPorEvento.clear();

    return carregar(idPropriedade);
  }

  void sincronizarCom(int geracaoDoCache) {
    if (geracaoDoCache == _geracaoDoCacheVista) return;

    _geracaoDoCacheVista = geracaoDoCache;
    recarregar();
  }

  void reconectarSeCaiu() => _canal.reconectarSeCaiu();

  Future<bool> marcarComoLida(NotificacaoAgrupada grupo) => _marcar([grupo]);

  Future<bool> marcarTodasComoLidas() => _marcar(naoLidasSemPendencia);

  Future<void> marcarLidasSemAcaoPendente() async {
    final semAcao = _grupos
        .where((grupo) => !grupo.lida)
        .where((grupo) => !aguardaResposta(grupo))
        .toList();

    if (semAcao.isEmpty) return;

    await _marcar(semAcao);
  }

  Future<void> encerrarVisita() async {
    await marcarLidasSemAcaoPendente();
    await sincronizarLeituras();
  }

  Future<void> sincronizarLeituras() async {
    if (!_leituras.temPendentes) return;

    final enviou = await _cargaLeitura.executar(
      chamada: () => _service.marcarComoLidas(_leituras.pendentes.toList()),
      aoFalhar: () => false,
    );

    if (enviou) return;

    _falhaDeLeitura = _cargaLeitura.mensagemErro ??
        'O servidor não confirmou as notificações marcadas como lidas. '
        'Elas voltam a ser enviadas na próxima abertura da tela.';
  }

  Future<bool> excluirAtividade(NotificacaoAgrupada grupo) {
    final idTrato = atividadeDe(grupo)?.id;

    if (idTrato == null) return Future.value(false);

    return cargaPrincipal.executar(
      chamada: () async {
        final sucesso = await _tratoService.excluir(idTrato);

        if (sucesso) _removerEvento(grupo.idEvento);

        return sucesso;
      },
      aoFalhar: () => false,
    );
  }

  void aposEdicao(NotificacaoAgrupada grupo) => _removerEvento(grupo.idEvento);

  @override
  void dispose() {
    _escuta?.cancel();
    _canal.dispose();
    super.dispose();
  }

  void _conectar() {
    _escuta ??= _canal.notificacoes.listen(_aoReceber);
    _canal.conectar();
  }

  void _aoReceber(Notificacao notificacao) {
    if (notificacao.idPropriedade != _idPropriedadeAtual) return;
    if (!notificacao.ehInterpretavel) return;
    if (_notificacoes.any((atual) => atual.id == notificacao.id)) return;

    _notificacoes = [notificacao, ..._notificacoes];
    _reagrupar();
    notificarSeVivo();

    _carregarAtividades();
  }

  Future<bool> _marcar(List<NotificacaoAgrupada> alvos) {
    final permitidos = alvos.where((grupo) => !aguardaResposta(grupo)).toList();

    if (permitidos.isEmpty) return Future.value(alvos.isEmpty);

    final ids = permitidos.expand((grupo) => grupo.ids).toList();

    return _cargaLeitura.executar(
      chamada: () async {
        await _leituras.marcar(ids);
        _aplicarLeitura(ids);

        return true;
      },
      aoFalhar: () => false,
    );
  }

  void _aplicarLeitura(List<int> ids) {
    final lidos = ids.toSet();

    _notificacoes = _notificacoes
        .map(
          (notificacao) =>
              lidos.contains(notificacao.id) ? notificacao.comoLida() : notificacao,
        )
        .toList();

    _reagrupar();
  }

  void _removerEvento(int idEvento) {
    _atividadesPorEvento.remove(idEvento);

    _notificacoes = _notificacoes
        .where((notificacao) => notificacao.idEvento != idEvento)
        .toList();

    _reagrupar();
    notificarSeVivo();
  }

  void _reagrupar() => _grupos = NotificacaoAgrupada.agrupar(_notificacoes);

  Future<void> _carregarAtividades() {
    final pendentes = _grupos
        .where(
          (grupo) => grupo.tipoEvento == TipoEventoNotificado.tratosCulturais,
        )
        .map((grupo) => grupo.idEvento)
        .where((idEvento) => !_atividadesPorEvento.containsKey(idEvento))
        .toSet();

    if (pendentes.isEmpty) return Future.value();

    return _cargaAtividades.executar<void>(
      chamada: () => Future.wait(pendentes.map(_carregarAtividade)),
      aoFalhar: () {},
    );
  }

  Future<void> _carregarAtividade(int idEvento) async {
    _atividadesPorEvento[idEvento] = await _tratoService.buscarPorId(idEvento);
  }

  List<SecaoDeNotificacoes> _secoes(List<NotificacaoAgrupada> grupos) {
    final pendentes = grupos.where(aguardaResposta).toList();
    final lembretes = grupos.where((grupo) => !aguardaResposta(grupo)).toList();

    final deHoje = _comHorizonte(lembretes, HorizonteDaNotificacao.hoje);
    final deAmanha = _comHorizonte(lembretes, HorizonteDaNotificacao.amanha);
    final proximas = _comHorizonte(lembretes, HorizonteDaNotificacao.proximos);
    final comecadas = _comHorizonte(lembretes, HorizonteDaNotificacao.vencido);

    return [
      if (pendentes.isNotEmpty)
        SecaoDeNotificacoes(
          'Precisa de resposta',
          _ordenar(pendentes, crescente: false),
        ),
      if (deHoje.isNotEmpty)
        SecaoDeNotificacoes(
          'Acontece hoje',
          _ordenar(deHoje, crescente: true),
        ),
      if (deAmanha.isNotEmpty)
        SecaoDeNotificacoes(
          'Acontece amanhã',
          _ordenar(deAmanha, crescente: true),
        ),
      if (proximas.isNotEmpty)
        SecaoDeNotificacoes(
          'Próximos dias',
          _ordenar(proximas, crescente: true),
        ),
      if (comecadas.isNotEmpty)
        SecaoDeNotificacoes(
          'Já começaram',
          _ordenar(comecadas, crescente: false),
        ),
    ];
  }

  List<NotificacaoAgrupada> _comHorizonte(
    List<NotificacaoAgrupada> grupos,
    HorizonteDaNotificacao horizonte,
  ) =>
      grupos.where((grupo) => _horizonteDe(grupo) == horizonte).toList();

  List<NotificacaoAgrupada> _ordenar(
    List<NotificacaoAgrupada> grupos, {
    required bool crescente,
  }) {
    final ordenados = [...grupos]..sort((a, b) {
        final dataA = dataDoEvento(a);
        final dataB = dataDoEvento(b);

        return crescente ? dataA.compareTo(dataB) : dataB.compareTo(dataA);
      });

    return ordenados;
  }
}
