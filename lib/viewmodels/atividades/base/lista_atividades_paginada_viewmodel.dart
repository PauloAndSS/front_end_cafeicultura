import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Páginas já baixadas de um filtro, e o estado da requisição em voo nele.
///
/// Carga e erro moram aqui, e não no ViewModel, porque a tela mantém o
/// segmentado visível durante a busca: o usuário pode tocar num segundo filtro
/// enquanto o primeiro ainda carrega. Com uma flag só, a segunda chamada era
/// engolida pela guarda de "já estou carregando" e aquele filtro ficava vazio
/// para sempre, exibindo a mensagem de lista vazia como se o servidor não
/// tivesse nada.
class _PaginasDoStatus<T> {
  final List<T> itens = [];

  /// 0 significa "nenhuma página ainda" — é o que distingue um filtro nunca
  /// visitado de um filtro que voltou vazio do servidor.
  int ultimaPaginaCarregada = 0;

  int totalPaginas = 1;

  /// Primeira página deste filtro.
  bool isLoading = false;

  /// Páginas seguintes deste filtro.
  bool isCarregandoMais = false;

  String? mensagemErro;

  bool get vazio => ultimaPaginaCarregada == 0;

  bool get temMais => ultimaPaginaCarregada < totalPaginas;

  /// Já há requisição em voo neste filtro — de qualquer das duas naturezas.
  bool get ocupado => isLoading || isCarregandoMais;

  /// As flags de carga caem junto com os itens: quem estava no ar vai descartar
  /// a própria resposta, então continuar marcado como ocupado só impediria a
  /// busca nova de começar.
  void limpar() {
    itens.clear();
    ultimaPaginaCarregada = 0;
    totalPaginas = 1;
    mensagemErro = null;
    isLoading = false;
    isCarregandoMais = false;
  }
}

/// Listagem de atividades **filtrada por status no servidor e paginada**.
///
/// Cada filtro guarda as próprias páginas **e o próprio estado de carga** pelo
/// tempo da sessão: voltar a um segmento já visitado é instantâneo, e dois
/// segmentos podem estar buscando ao mesmo tempo sem um cancelar o outro.
/// [recarregar] é o único ponto que os invalida — refresh e retorno de
/// cadastro/edição passam por lá.
///
/// A base não sabe **de onde** vêm as atividades: o escopo entra como o
/// parâmetro de tipo [E], e as subclasses abaixo dizem se ele é o
/// `idPropriedade` da aba ou o par `(idPropriedade, idTalhao)` da seção do
/// talhão. Records têm igualdade por valor, então o par funciona como chave sem
/// precisar de classe própria.
///
/// [E] tipado, e não um `Object` opaco, porque o escopo é **devolvido** à
/// subclasse em [buscarPagina] e [prepararPrimeiraPagina]. Com um `Object`
/// privado a subclasse teria de guardar a própria cópia dos ids para poder
/// montar a requisição — exatamente o estado duplicado que esta base existe
/// para concentrar.
abstract class ListaAtividadesPaginadaViewModel<T extends EventoAgricola,
    E extends Object> extends ChangeNotifier with DescarteSeguroMixin {
  /// Os segmentos que a tela oferece, na ordem em que aparecem. `null` é
  /// "Todas" — o filtro que **omite** `status` da query.
  ///
  /// É getter, e não constante, porque as duas telas divergem: a aba sempre
  /// manda um status, a seção do talhão oferece o "Todas" a mais.
  @protected
  List<StatusEvento?> get filtrosDisponiveis => StatusEvento.values;

  /// Os mesmos segmentos, para a tela desenhar o filtro. A View não deveria
  /// precisar saber quais status esta listagem oferece — ela pergunta.
  List<StatusEvento?> get filtros => filtrosDisponiveis;

  /// Segmento aceso quando a tela abre.
  @protected
  StatusEvento? get filtroInicial => StatusEvento.emAndamento;

  /// `late` porque o inicializador lê [filtrosDisponiveis], e inicializador de
  /// campo não enxerga `this`.
  late final Map<StatusEvento?, _PaginasDoStatus<T>> _porStatus = {
    for (final filtro in filtrosDisponiveis) filtro: _PaginasDoStatus<T>(),
  };

  E? _escopo;

  /// Sobe a cada limpeza do cache. Uma requisição carrega a geração em que
  /// nasceu e desiste de escrever se ela já passou — sem isso, a página 4 que
  /// estava no ar quando o usuário deu refresh voltaria e se instalaria sozinha
  /// num bucket recém-esvaziado, com `ultimaPaginaCarregada = 4` e só os itens
  /// dela na lista.
  int _geracao = 0;

  late StatusEvento? _statusAtual = filtroInicial;
  StatusEvento? get statusAtual => _statusAtual;

  /// Primeira página do filtro atual. A tela põe um spinner no lugar dos cards
  /// enquanto isto for `true` — só ali, o segmentado acima continua desenhado.
  bool get isLoading => _paginasAtuais.isLoading;

  /// Páginas seguintes. Separado de [isLoading] porque a rolagem infinita só
  /// pode mostrar um indicador no rodapé — substituir a lista por um spinner
  /// arrancaria o conteúdo debaixo do dedo do usuário.
  bool get isCarregandoMais => _paginasAtuais.isCarregandoMais;

  /// Erro do filtro atual. Um filtro que falhou não contamina os outros.
  String? get mensagemErro => _paginasAtuais.mensagemErro;

  /// Itens já carregados do filtro atual.
  List<T> get atividades => List.unmodifiable(_paginasAtuais.itens);

  /// Se ainda há página para pedir no filtro atual.
  bool get temMais => _paginasAtuais.temMais;

  _PaginasDoStatus<T> get _paginasAtuais {
    assert(
      _porStatus.containsKey(_statusAtual),
      'O filtro atual precisa estar em filtrosDisponiveis.',
    );

    return _porStatus[_statusAtual]!;
  }

  /// Mensagem do `catch` genérico. Termina antes de "Tente novamente" — a base
  /// completa a frase.
  @protected
  String get erroInternoAoCarregar;

  /// Busca uma página do [status] dentro do [escopo]; `status` nulo pede sem
  /// filtro. A rota fixa o tamanho da página, então não há `limite` para passar.
  @protected
  Future<ResultadoPaginadoDTO<T>> buscarPagina(
    E escopo,
    StatusEvento? status,
    int pagina,
  );

  /// Trabalho que acompanha a primeira página e não se repete nas seguintes —
  /// hoje, resolver os nomes dos talhões na aba da propriedade.
  ///
  /// Devolver `null` (o padrão) significa "nada a preparar", e é o caso da
  /// seção do talhão, onde o nome já vem pronto de quem abriu a tela.
  @protected
  Future<void>? prepararPrimeiraPagina(E escopo) => null;

  /// Ponto de entrada das subclasses: garante a primeira página do filtro atual
  /// dentro de [escopo].
  ///
  /// Trocar de escopo descarta todos os filtros — as páginas do anterior não
  /// dizem nada sobre o novo.
  ///
  /// É chamado a cada `didChangeDependencies` da tela, então não basta olhar
  /// "está vazio": um filtro que falhou também está, e retentar aqui faria a
  /// tela bater de novo numa rota fora do ar sozinha. Erro pendente espera o
  /// botão, como em [selecionarStatus].
  @protected
  Future<void> carregarEscopo(E escopo, {bool forcar = false}) async {
    if (_escopo != escopo) {
      _escopo = escopo;
      _limparTodos();
    }

    if (!forcar) {
      final paginas = _paginasAtuais;
      if (!paginas.vazio || paginas.mensagemErro != null) return;
    } else {
      _limparTodos();
    }

    await _carregarProximaPagina(primeira: true);
  }

  /// Troca o segmento. Só vai à rede se aquele filtro ainda não tiver nada.
  ///
  /// Com erro pendente naquele filtro, quem retenta é o botão
  /// ([tentarNovamente]): buscar de novo a cada toque no segmento transformaria
  /// uma rota fora do ar numa requisição por toque.
  Future<void> selecionarStatus(StatusEvento? status) async {
    if (status == _statusAtual) return;

    // Só existe bucket para o que está em [filtrosDisponiveis]; aceitar outro
    // valor faria o getter das páginas estourar no null-check do mapa.
    if (!_porStatus.containsKey(status)) return;

    _statusAtual = status;
    notificarComSeguranca();

    final paginas = _paginasAtuais;
    if (paginas.vazio && paginas.mensagemErro == null) {
      await _carregarProximaPagina(primeira: true);
    }
  }

  /// Próxima página do filtro atual — chamado pelo fim da rolagem.
  Future<void> carregarMaisPagina() {
    if (!_paginasAtuais.temMais) return Future.value();

    return _carregarProximaPagina(primeira: false);
  }

  /// Refaz a página que falhou no filtro atual — é o botão "Tentar novamente".
  ///
  /// Escolhe sozinho entre primeira e próxima porque a diferença entre as duas
  /// é só onde o indicador aparece: no lugar da lista quando não há nada, no
  /// rodapé quando já há cards na tela.
  Future<void> tentarNovamente() =>
      _carregarProximaPagina(primeira: _paginasAtuais.vazio);

  /// Descarta tudo e rebusca a primeira página do filtro atual.
  ///
  /// Invalida todos os filtros de propósito: confirmar uma atividade a move de
  /// "agendada" para "em andamento", então manter os outros em cache deixaria a
  /// mesma atividade em dois segmentos.
  Future<void> recarregar() async {
    final escopo = _escopo;
    if (escopo == null) return;

    await carregarEscopo(escopo, forcar: true);
  }

  Future<void> _carregarProximaPagina({required bool primeira}) async {
    final escopo = _escopo;
    if (escopo == null) return;

    final status = _statusAtual;
    final paginas = _porStatus[status]!;

    // A guarda é do filtro, não do ViewModel: dois segmentos podem estar
    // buscando ao mesmo tempo, e são requisições independentes.
    if (paginas.ocupado) return;

    final pagina = paginas.ultimaPaginaCarregada + 1;
    final geracao = _geracao;

    if (primeira) {
      paginas.isLoading = true;
    } else {
      paginas.isCarregandoMais = true;
    }
    paginas.mensagemErro = null;
    notificarComSeguranca();

    final preparo = primeira ? prepararPrimeiraPagina(escopo) : null;

    String? erro;

    try {
      final resultado = await buscarPagina(escopo, status, pagina);

      // Trocar de *segmento* não descarta nada: `paginas` já aponta para o
      // bucket certo e os itens ficam lá esperando o usuário voltar àquele
      // filtro. O que descarta é o cache ter sido invalidado no meio do
      // caminho — troca de escopo ou refresh.
      if (geracao == _geracao) {
        paginas.itens.addAll(resultado.data);
        paginas.ultimaPaginaCarregada = pagina;
        paginas.totalPaginas = resultado.totalPaginas;
        // A ordem é a que o backend devolveu. Reordenar por página embaralharia
        // a sequência na fronteira entre uma página e a seguinte.
      }
    } on ApiException catch (e) {
      erro = e.mensagem;
    } catch (e) {
      erro = '$erroInternoAoCarregar Tente novamente mais tarde.';
      debugPrint('Erro ao carregar página $pagina de ${status?.name ?? 'todas'}: $e');
    } finally {
      if (preparo != null) await preparo;

      // Mesma geração, mesma regra: uma busca já obsoleta não põe erro sobre
      // dado novo nem apaga o indicador da busca que a substituiu.
      if (geracao == _geracao) {
        paginas.mensagemErro = erro;
        paginas.isLoading = false;
        paginas.isCarregandoMais = false;
      }

      notificarComSeguranca();
    }
  }

  /// Invalida tudo o que está em cache **e o que está no ar**: os buckets voltam
  /// a "nunca visitado" e a geração sobe, o que faz as requisições pendentes
  /// descartarem a própria resposta ao voltar.
  void _limparTodos() {
    _geracao++;

    for (final paginas in _porStatus.values) {
      paginas.limpar();
    }
  }
}

/// Atividades da propriedade inteira — a aba de listagem.
///
/// Traz [CarregarTalhoesMixin] porque o payload da listagem só devolve
/// `idTalhao`: sem os talhões não há como o card mostrar o nome. Eles entram
/// junto da primeira página, via [prepararPrimeiraPagina] — o mapa de nomes é o
/// mesmo para a propriedade inteira e não muda de uma página para a seguinte.
abstract class ListaAtividadesDaPropriedadePaginadaViewModel<
        T extends EventoAgricola>
    extends ListaAtividadesPaginadaViewModel<T, int> with CarregarTalhoesMixin {
  /// Estreita o retorno para não-nulo: esta variante não oferece o segmento
  /// "Todas", então `null` é impossível aqui. Sem isso, a tela da aba teria de
  /// tratar um caso que ela nunca produz — e o `switch` exaustivo sobre
  /// [StatusEvento] que monta a mensagem de lista vazia deixaria de compilar.
  @override
  StatusEvento get statusAtual => super.statusAtual!;

  Future<void> carregar(int idPropriedade, {bool forcar = false}) =>
      carregarEscopo(idPropriedade, forcar: forcar);

  @override
  Future<void>? prepararPrimeiraPagina(int escopo) => carregarTalhoes(escopo);
}

/// Atividades de um talhão só — a seção dentro do detalhe do talhão.
///
/// Sem o mixin de talhões: quem abriu a tela já sabe o nome e o passa adiante.
///
/// Oferece o segmento "Todas" que a aba não tem, e abre nele: a seção é um
/// resumo do que aconteceu naquele talhão, e começar filtrado esconderia parte
/// do histórico logo na abertura.
abstract class ListaAtividadesDoTalhaoPaginadaViewModel<
        T extends EventoAgricola>
    extends ListaAtividadesPaginadaViewModel<T, (int idPropriedade, int idTalhao)> {
  @override
  List<StatusEvento?> get filtrosDisponiveis =>
      const [null, ...StatusEvento.values];

  @override
  StatusEvento? get filtroInicial => null;

  Future<void> carregar(
    int idPropriedade,
    int idTalhao, {
    bool forcar = false,
  }) {
    return carregarEscopo((idPropriedade, idTalhao), forcar: forcar);
  }

  @override
  Future<ResultadoPaginadoDTO<T>> buscarPagina(
    (int idPropriedade, int idTalhao) escopo,
    StatusEvento? status,
    int pagina,
  ) {
    return buscarNoTalhao(escopo.$1, escopo.$2, status, pagina);
  }

  /// Desdobra o record do escopo nos dois ids, para a subclasse concreta não
  /// precisar conhecer a forma da chave de cache.
  @protected
  Future<ResultadoPaginadoDTO<T>> buscarNoTalhao(
    int idPropriedade,
    int idTalhao,
    StatusEvento? status,
    int pagina,
  );
}
