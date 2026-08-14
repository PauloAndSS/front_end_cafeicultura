import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/dtos/paginacao_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/carregar_talhoes_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/descarte_seguro_mixin.dart';

/// Páginas já baixadas de um status, e o estado da requisição em voo nele.
///
/// Carga e erro moram aqui, e não no ViewModel, porque a tela mantém o
/// segmentado visível durante a busca: o usuário pode tocar num segundo status
/// enquanto o primeiro ainda carrega. Com uma flag só, a segunda chamada era
/// engolida pela guarda de "já estou carregando" e aquele status ficava vazio
/// para sempre, exibindo a mensagem de lista vazia como se o servidor não
/// tivesse nada.
class _PaginasDoStatus<T> {
  final List<T> itens = [];

  /// 0 significa "nenhuma página ainda" — é o que distingue um status nunca
  /// visitado de um status que voltou vazio do servidor.
  int ultimaPaginaCarregada = 0;

  int totalPaginas = 1;

  /// Primeira página deste status.
  bool isLoading = false;

  /// Páginas seguintes deste status.
  bool isCarregandoMais = false;

  String? mensagemErro;

  bool get vazio => ultimaPaginaCarregada == 0;

  bool get temMais => ultimaPaginaCarregada < totalPaginas;

  /// Já há requisição em voo neste status — de qualquer das duas naturezas.
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

/// Listagem de atividades de uma propriedade **filtrada por status no servidor
/// e paginada**.
///
/// Não estende `ListaAtividadesViewModel`: aquela base carrega a coleção inteira
/// e filtra por status na memória (`porStatus`), o que é exatamente o que deixa
/// de ser possível quando o status vira query param e a resposta vem em páginas
/// de 25. A seção de atividades do talhão continua usando aquela.
///
/// Cada status guarda as próprias páginas **e o próprio estado de carga** pelo
/// tempo da sessão: voltar a um segmento já visitado é instantâneo, e dois
/// segmentos podem estar buscando ao mesmo tempo sem um cancelar o outro.
/// [recarregar] é o único ponto que invalida os três — refresh e retorno de
/// cadastro/edição passam por lá.
///
/// Traz [CarregarTalhoesMixin] porque o payload da listagem só devolve
/// `idTalhao`: sem os talhões não há como o card mostrar o nome.
abstract class ListaAtividadesPaginadaViewModel<T extends EventoAgricola>
    extends ChangeNotifier with DescarteSeguroMixin, CarregarTalhoesMixin {
  final Map<StatusEvento, _PaginasDoStatus<T>> _porStatus = {
    for (final status in StatusEvento.values) status: _PaginasDoStatus<T>(),
  };

  int? _idPropriedade;

  /// Sobe a cada limpeza do cache. Uma requisição carrega a geração em que
  /// nasceu e desiste de escrever se ela já passou — sem isso, a página 4 que
  /// estava no ar quando o usuário deu refresh voltaria e se instalaria sozinha
  /// num bucket recém-esvaziado, com `ultimaPaginaCarregada = 4` e só os itens
  /// dela na lista.
  int _geracao = 0;

  StatusEvento _statusAtual = StatusEvento.emAndamento;
  StatusEvento get statusAtual => _statusAtual;

  /// Primeira página do status atual. A tela põe um spinner no lugar dos cards
  /// enquanto isto for `true` — só ali, o calendário e o segmentado acima
  /// continuam desenhados.
  bool get isLoading => _paginasAtuais.isLoading;

  /// Páginas seguintes. Separado de [isLoading] porque a rolagem infinita só
  /// pode mostrar um indicador no rodapé — substituir a lista por um spinner
  /// arrancaria o conteúdo debaixo do dedo do usuário.
  bool get isCarregandoMais => _paginasAtuais.isCarregandoMais;

  /// Erro do status atual. Um status que falhou não contamina os outros dois.
  String? get mensagemErro => _paginasAtuais.mensagemErro;

  /// Itens já carregados do status atual.
  List<T> get atividades => List.unmodifiable(_paginasAtuais.itens);

  /// Se ainda há página para pedir no status atual.
  bool get temMais => _paginasAtuais.temMais;

  _PaginasDoStatus<T> get _paginasAtuais => _porStatus[_statusAtual]!;

  /// Mensagem do `catch` genérico. Termina antes de "Tente novamente" — a base
  /// completa a frase.
  @protected
  String get erroInternoAoCarregar;

  /// Busca uma página do [status]. A rota fixa o tamanho da página, então não há
  /// `limite` para passar.
  @protected
  Future<ResultadoPaginadoDTO<T>> buscarPagina(
    int idPropriedade,
    StatusEvento status,
    int pagina,
  );

  /// Ponto de entrada da tela: garante a primeira página do status atual.
  ///
  /// Trocar de propriedade descarta os três status — as páginas da anterior não
  /// dizem nada sobre a nova.
  ///
  /// É chamado a cada `didChangeDependencies` da tela, então não basta olhar
  /// "está vazio": um status que falhou também está, e retentar aqui faria a
  /// tela bater de novo numa rota fora do ar sozinha. Erro pendente espera o
  /// botão, como em [selecionarStatus].
  Future<void> carregar(int idPropriedade, {bool forcar = false}) async {
    if (_idPropriedade != idPropriedade) {
      _idPropriedade = idPropriedade;
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

  /// Troca o segmento. Só vai à rede se aquele status ainda não tiver nada.
  ///
  /// Com erro pendente naquele status, quem retenta é o botão
  /// ([tentarNovamente]): buscar de novo a cada toque no segmento transformaria
  /// uma rota fora do ar numa requisição por toque.
  Future<void> selecionarStatus(StatusEvento status) async {
    if (status == _statusAtual) return;

    _statusAtual = status;
    notificarComSeguranca();

    final paginas = _paginasAtuais;
    if (paginas.vazio && paginas.mensagemErro == null) {
      await _carregarProximaPagina(primeira: true);
    }
  }

  /// Próxima página do status atual — chamado pelo fim da rolagem.
  Future<void> carregarMaisPagina() {
    if (!_paginasAtuais.temMais) return Future.value();

    return _carregarProximaPagina(primeira: false);
  }

  /// Refaz a página que falhou no status atual — é o botão "Tentar novamente".
  ///
  /// Escolhe sozinho entre primeira e próxima porque a diferença entre as duas
  /// é só onde o indicador aparece: no lugar da lista quando não há nada, no
  /// rodapé quando já há cards na tela.
  Future<void> tentarNovamente() =>
      _carregarProximaPagina(primeira: _paginasAtuais.vazio);

  /// Descarta tudo e rebusca a primeira página do status atual.
  ///
  /// Invalida os três status de propósito: confirmar uma atividade a move de
  /// "agendada" para "em andamento", então manter os outros dois em cache
  /// deixaria a mesma atividade em dois segmentos.
  Future<void> recarregar() async {
    final idPropriedade = _idPropriedade;
    if (idPropriedade == null) return;

    await carregar(idPropriedade, forcar: true);
  }

  Future<void> _carregarProximaPagina({required bool primeira}) async {
    final idPropriedade = _idPropriedade;
    if (idPropriedade == null) return;

    final status = _statusAtual;
    final paginas = _porStatus[status]!;

    // A guarda é do status, não do ViewModel: dois segmentos podem estar
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

    // Os talhões só na primeira página: o mapa de nomes é o mesmo para a
    // propriedade inteira e não muda entre uma página e a seguinte.
    final buscaTalhoes = primeira ? carregarTalhoes(idPropriedade) : null;

    String? erro;

    try {
      final resultado = await buscarPagina(idPropriedade, status, pagina);

      // Trocar de *segmento* não descarta nada: `paginas` já aponta para o
      // bucket certo e os itens ficam lá esperando o usuário voltar àquele
      // status. O que descarta é o cache ter sido invalidado no meio do
      // caminho — troca de propriedade ou refresh.
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
      debugPrint('Erro ao carregar página $pagina de ${status.name}: $e');
    } finally {
      if (buscaTalhoes != null) await buscaTalhoes;

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
