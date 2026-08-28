import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_notificacao.dart';
import 'package:frond_end_cafeicultura_mobile/http/websocket/canal_notificacoes.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao_agrupada.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
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

  final Map<int, TratoCultural> _atividadesPorEvento = {};

  List<Notificacao> _notificacoes = [];
  List<NotificacaoAgrupada> _grupos = [];

  StreamSubscription<Notificacao>? _escuta;

  int? _idPropriedadeAtual;
  int? _propriedadeJaTentada;
  int _geracaoDoCacheVista = 0;

  List<NotificacaoAgrupada> get grupos => List.unmodifiable(_grupos);

  List<NotificacaoAgrupada> get naoLidas =>
      _grupos.where((grupo) => !grupo.lida).toList();

  List<NotificacaoAgrupada> get lidas =>
      _grupos.where((grupo) => grupo.lida).toList();

  int get quantidadeNaoLidas => naoLidas.length;

  bool get temNaoLidas => quantidadeNaoLidas > 0;

  bool get vazio => _grupos.isEmpty;

  bool get marcandoLeitura => _cargaLeitura.isLoading;

  String? get mensagemErroLeitura => _cargaLeitura.mensagemErro;

  List<SecaoDeNotificacoes> get secoesNaoLidas => _secoes(naoLidas);

  List<SecaoDeNotificacoes> get secoesLidas => _secoes(lidas);

  TratoCultural? atividadeDe(NotificacaoAgrupada grupo) =>
      _atividadesPorEvento[grupo.idEvento];

  bool estaConfirmada(NotificacaoAgrupada grupo) =>
      atividadeDe(grupo)?.finalizado ?? false;

  DateTime dataDoEvento(NotificacaoAgrupada grupo) =>
      atividadeDe(grupo)?.dataInicio ?? grupo.dataPrevistaDoEvento;

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

  Future<bool> marcarTodasComoLidas() => _marcar(naoLidas);

  Future<void> marcarLidasSemAcaoPendente() async {
    final semAcao = naoLidas
        .where((grupo) => !grupo.ehConfirmacao || estaConfirmada(grupo))
        .toList();

    if (semAcao.isEmpty) return;

    await _marcar(semAcao);
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
    if (alvos.isEmpty) return Future.value(true);

    final ids = alvos.expand((grupo) => grupo.ids).toList();

    return _cargaLeitura.executar(
      chamada: () async {
        await _service.marcarComoLidas(ids);
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
    final precisamDeResposta = grupos
        .where((grupo) => grupo.ehConfirmacao && !estaConfirmada(grupo))
        .toList();

    final jaConfirmadas = grupos
        .where((grupo) => grupo.ehConfirmacao && estaConfirmada(grupo))
        .toList();

    final futuras = grupos.where((grupo) => !grupo.ehConfirmacao).toList();

    final iminentes = futuras
        .where((grupo) => diasAPartirDeHoje(dataDoEvento(grupo)) <= 1)
        .toList();

    final proximas = futuras
        .where((grupo) => diasAPartirDeHoje(dataDoEvento(grupo)) > 1)
        .toList();

    return [
      if (precisamDeResposta.isNotEmpty)
        SecaoDeNotificacoes(
          'Precisa de resposta',
          _ordenar(precisamDeResposta, crescente: false),
        ),
      if (iminentes.isNotEmpty)
        SecaoDeNotificacoes(
          'Acontece amanhã',
          _ordenar(iminentes, crescente: true),
        ),
      if (proximas.isNotEmpty)
        SecaoDeNotificacoes(
          'Próximos dias',
          _ordenar(proximas, crescente: true),
        ),
      if (jaConfirmadas.isNotEmpty)
        SecaoDeNotificacoes(
          'Já confirmadas',
          _ordenar(jaConfirmadas, crescente: false),
        ),
    ];
  }

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
