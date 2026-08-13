// lib/views/talhao/detalhes_talhao_view.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/tratos_culturais_do_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/detalhes_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/filtro_status_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/widgets/seletor_tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:provider/provider.dart';

class DetalhesTalhaoView extends StatefulWidget {
  final Talhao talhao;

  const DetalhesTalhaoView({super.key, required this.talhao});

  @override
  State<DetalhesTalhaoView> createState() => _DetalhesTalhaoViewState();
}

class _DetalhesTalhaoViewState extends State<DetalhesTalhaoView> {
  final _viewModel = DetalhesTalhaoViewModel();

  /// ViewModel próprio para as atividades: o `isLoading` de [_viewModel] já
  /// desabilita os botões de encerrar/excluir, e recarregar a lista não pode
  /// bloquear essas ações.
  final _atividadesViewModel = TratosCulturaisDoTalhaoViewModel();

  TipoAtividade _tipoAtividade = TipoAtividade.tratosCulturais;

  StatusEvento _filtroAtividades = StatusEvento.emAndamento;

  @override
  void initState() {
    super.initState();

    // carregar notifica de forma síncrona: chamar aqui direto dispararia
    // rebuild no meio do primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAtividades();
    });
  }

  @override
  void dispose() {
    _atividadesViewModel.dispose();
    super.dispose();
  }

  /// Gancho de extensão do select: cada tipo novo entra como um `case`. Os
  /// ainda não implementados não disparam requisição — é o que mantém a
  /// abertura da tela barata.
  void _carregarTipoSelecionado({bool forcar = false}) {
    switch (_tipoAtividade) {
      case TipoAtividade.tratosCulturais:
        _carregarAtividades(forcar: forcar);
      case TipoAtividade.colheitas:
      case TipoAtividade.preSecagens:
      case TipoAtividade.despolpagens:
      case TipoAtividade.fermentacoes:
      case TipoAtividade.secagens:
      case TipoAtividade.pilagens:
        break;
    }
  }

  void _carregarAtividades({bool forcar = false}) {
    final idPropriedade = context
        .read<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;
    final idTalhao = widget.talhao.id;

    if (idPropriedade == null || idTalhao == null) return;

    _atividadesViewModel.carregar(idPropriedade, idTalhao, forcar: forcar);
  }

  Future<void> _abrirDetalhesTrato(TratoCultural trato) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesTratoCulturalView(
          trato: trato,
          nomeTalhao: widget.talhao.nomeExibicao,
        ),
      ),
    );

    // forcar: o trato pode ter sido finalizado ou editado lá dentro, então o
    // cache está velho.
    if (alterou == true && mounted) {
      _carregarAtividades(forcar: true);
    }
  }

  void _onSucesso(String mensagem) {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    if (propriedadesVM.idPropriedadeSelecionada != null) {
      context.read<TalhoesViewModel>().carregarTalhoes(
        propriedadesVM.idPropriedadeSelecionada!,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _onErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _confirmarEncerramento(BuildContext context) async {
    final DateTime hoje = DateTime.now();

    final DateTime? dataFimEscolhida = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: widget.talhao.dataInicio,
      lastDate: hoje,
      helpText: 'Selecione a data de encerramento do talhão',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF67835C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataFimEscolhida == null) return;
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Talhão'),
        content: Text(
          'Deseja realmente encerrar o talhão "${widget.talhao.nomeExibicao}" na data ${dataFimEscolhida.day.toString().padLeft(2, '0')}/${dataFimEscolhida.month.toString().padLeft(2, '0')}/${dataFimEscolhida.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encerrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _viewModel.encerrar(
        widget.talhao.id!,
        dataFimEscolhida,
      );

      if (!mounted) return;

      if (sucesso == true) {
        _onSucesso('Talhão encerrado com sucesso!');
      } else {
        _onErro(_viewModel.mensagemErro ?? 'Erro ao encerrar talhão.');
      }
    }
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Talhão'),
        content: Text(
          'Tem certeza que deseja excluir permanentemente o talhão "${widget.talhao.nomeExibicao}"?\n\nEsta ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _viewModel.excluir(widget.talhao.id!);

      if (!mounted) return;

      if (sucesso == true) {
        _onSucesso('Talhão excluído com sucesso!');
      } else {
        _onErro(_viewModel.mensagemErro ?? 'Erro ao excluir talhão.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool estaEncerrado = widget.talhao.dataFim != null || widget.talhao.arquivado == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.talhao.nomeExibicao,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF67835C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Informações do Talhão',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF67835C),
                            ),
                          ),
                          if (estaEncerrado)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Encerrado',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Nome:', widget.talhao.nomeExibicao),
                      const SizedBox(height: 12),
                      _buildInfoRow('Espécie:', widget.talhao.especieFormatada),
                      const SizedBox(height: 12),
                      _buildInfoRow('Variedades de Café:', widget.talhao.variedadesTexto),
                      const SizedBox(height: 12),
                      _buildInfoRow('Quantidade de Pés:', widget.talhao.qtdPeCafeFormatada),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tamanho:', widget.talhao.tamanhoFormatado),
                      const SizedBox(height: 12),
                      _buildInfoRow('Data de Início:', widget.talhao.dataInicioFormatada),
                      if (widget.talhao.dataFimFormatada != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow('Data de Encerramento:', widget.talhao.dataFimFormatada!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (estaEncerrado)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este talhão já foi encerrado e não pode mais ser modificado.',
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _viewModel.isLoading
                          ? 'Encerrando...'
                          : 'Encerrar Talhão',
                      onPressed: _viewModel.isLoading
                          ? null
                          : () => _confirmarEncerramento(context),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _viewModel.isLoading ? 'Aguarde...' : 'Excluir Talhão',
                    onPressed: _viewModel.isLoading ? null : () => _confirmarExclusao(context),
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                _construirSecaoAtividades(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ListenableBuilder próprio: alternar o filtro ou recarregar a lista não
  /// deve reconstruir o cartão de informações nem os botões acima.
  Widget _construirSecaoAtividades() {
    return ListenableBuilder(
      listenable: _atividadesViewModel,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atividades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SeletorTipoAtividade(
              selecionado: _tipoAtividade,
              onSelecionar: (novoTipo) {
                setState(() {
                  _tipoAtividade = novoTipo;
                });
                _carregarTipoSelecionado();
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FiltroStatusAtividade(
                selecionado: _filtroAtividades,
                onSelecionar: (novoFiltro) {
                  setState(() {
                    _filtroAtividades = novoFiltro;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _construirCorpoAtividades(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _construirCorpoAtividades() {
    // Antes da cascata de estado: sem esta guarda, o spinner e o erro dos
    // tratos culturais vazariam para os tipos ainda não implementados.
    if (!atividadeImplementada(_tipoAtividade)) {
      return _construirTipoEmDesenvolvimento();
    }

    if (_atividadesViewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF67835C)),
        ),
      );
    }

    if (_atividadesViewModel.mensagemErro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            _atividadesViewModel.mensagemErro!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final tratosFiltrados = _atividadesViewModel.porStatus(_filtroAtividades);

    if (tratosFiltrados.isEmpty) {
      return _construirAtividadesVazias();
    }

    // Column em vez de ListView: a tela inteira já está num
    // SingleChildScrollView, e um ListView aninhado perderia a virtualização
    // de qualquer forma por causa do shrinkWrap.
    return Column(
      children: tratosFiltrados
          .map(
            (trato) => AtividadeCard(
              atividade: trato,
              nomeTalhao: widget.talhao.nomeExibicao,
              icone: Icons.grass,
              onTap: () => _abrirDetalhesTrato(trato),
            ),
          )
          .toList(),
    );
  }

  Widget _construirTipoEmDesenvolvimento() {
    return _construirCaixaAviso('${_tipoAtividade.rotulo} em desenvolvimento.');
  }

  Widget _construirAtividadesVazias() {
    final statusTexto = switch (_filtroAtividades) {
      StatusEvento.agendado => 'agendada',
      StatusEvento.emAndamento => 'em andamento',
      StatusEvento.finalizado => 'finalizada',
    };

    return _construirCaixaAviso(
      'Nenhuma atividade $statusTexto neste talhão.',
    );
  }

  /// Caixa neutra usada tanto para lista vazia quanto para tipo ainda não
  /// implementado — mesma moldura, só muda o texto.
  Widget _construirCaixaAviso(String mensagem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          mensagem,
          style: const TextStyle(fontSize: 14, color: Colors.black45),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}