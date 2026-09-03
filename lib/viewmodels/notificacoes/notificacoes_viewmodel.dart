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
  final Set<String> _vistas = {};

  List<Notificacao> _notificacoes = [];
  List<NotificacaoAgrupada> _grupos = [];

  StreamSubscription<Notificacao>? _escuta;

  int? _idPropriedadeAtual;
  int? _propriedadeJaTentada;
  int _geracaoDoCacheVista = 0;
  String? _falhaDeLeitura;

  List<NotificacaoAgrupada> get grupos => List.unmodifiable(_grupos);

  List<NotificacaoAgrupada> get _visiveis =>
      _grupos.where((grupo) => !estaConfirmada(grupo)).toList();

  List<NotificacaoAgrupada> get naoLidas =>
      _visiveis.where((grupo) => !grupo.lida).toList();

  List<NotificacaoAgrupada> get lidas =>
      _visiveis.where((grupo) => grupo.lida).toList();

  int get quantidadeNaoLidas => naoLidas.length;

  bool get temNaoLidas => quantidadeNaoLidas > 0;

  bool get vazio => _visiveis.isEmpty;

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

  Future<void> carregar(int idPropriedade) async {
    final trocouPropriedade = _idPropriedadeAtual != idPropriedade;

    if (trocouPropriedade) {
      _atividadesPorEvento.clear();
      _vistas.clear();
      _notificacoes = [];
      _grupos = [];
    }

    _idPropriedadeAtual = idPropriedade;
    _propriedadeJaTentada = idPropriedade;

    await cargaPrincipal.executar(
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

    await sincronizarLeituras();
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

  bool aguardaLeitura(NotificacaoAgrupada grupo) =>
      !grupo.lida && !grupo.ehConfirmacao;

  void registrarVista(NotificacaoAgrupada grupo) {
    if (!aguardaLeitura(grupo)) return;

    _vistas.add(grupo.representante.chaveDeAgrupamento);
  }

  Future<void> encerrarVisita() async {
    await _marcar(_gruposParaAutoLeitura());
    _vistas.clear();
    await sincronizarLeituras();
  }

  Future<void> sincronizarLeituras() async {
    if (!_leituras.temPendentes) return;

    final enviados = _leituras.pendentes.toList();

    final enviou = await _cargaLeitura.executar(
      chamada: () => _service.marcarComoLidas(enviados),
      aoFalhar: () => false,
    );

    if (enviou) {
      await _leituras.confirmar(enviados);
      _falhaDeLeitura = null;

      return;
    }

    _falhaDeLeitura = _cargaLeitura.mensagemErro ??
        'Não foi possível salvar as notificações lidas no servidor.';
  }

  String? consumirFalhaDeLeitura() {
    final falha = _falhaDeLeitura;

    _falhaDeLeitura = null;

    return falha;
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
        await _leituras.marcar(ids);
        _aplicarLeitura(ids);

        return true;
      },
      aoFalhar: () => false,
    );
  }

  List<NotificacaoAgrupada> _gruposParaAutoLeitura() => _grupos
      .where((grupo) => !grupo.lida)
      .where((grupo) => estaConfirmada(grupo) || _foiVista(grupo))
      .toList();

  bool _foiVista(NotificacaoAgrupada grupo) =>
      aguardaLeitura(grupo) &&
      _vistas.contains(grupo.representante.chaveDeAgrupamento);

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
    final precisamDeResposta =
        grupos.where((grupo) => grupo.ehConfirmacao).toList();

    final futuras = grupos.where((grupo) => !grupo.ehConfirmacao).toList();

    final jaComecaram = _porHorizonte(futuras, (dias) => dias < 0);
    final hoje = _porHorizonte(futuras, (dias) => dias == 0);
    final amanha = _porHorizonte(futuras, (dias) => dias == 1);
    final proximas = _porHorizonte(futuras, (dias) => dias > 1);

    return [
      if (precisamDeResposta.isNotEmpty)
        SecaoDeNotificacoes(
          'Precisa de resposta',
          _ordenar(precisamDeResposta, crescente: false),
        ),
      if (jaComecaram.isNotEmpty)
        SecaoDeNotificacoes(
          'Já começaram',
          _ordenar(jaComecaram, crescente: true),
        ),
      if (hoje.isNotEmpty)
        SecaoDeNotificacoes(
          'Acontece hoje',
          _ordenar(hoje, crescente: true),
        ),
      if (amanha.isNotEmpty)
        SecaoDeNotificacoes(
          'Acontece amanhã',
          _ordenar(amanha, crescente: true),
        ),
      if (proximas.isNotEmpty)
        SecaoDeNotificacoes(
          'Próximos dias',
          _ordenar(proximas, crescente: true),
        ),
    ];
  }

  List<NotificacaoAgrupada> _porHorizonte(
    List<NotificacaoAgrupada> futuras,
    bool Function(int dias) filtro,
  ) =>
      futuras
          .where((grupo) => filtro(diasAPartirDeHoje(dataDoEvento(grupo))))
          .toList();

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
