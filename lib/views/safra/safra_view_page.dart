import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:provider/provider.dart';

class SafraViewPage extends StatefulWidget {
  const SafraViewPage({super.key});

  @override
  State<SafraViewPage> createState() => _SafraViewPageState();
}

class _SafraViewPageState extends State<SafraViewPage> {
  int? _ultimaPropriedadeCarregada;

  /// Ordena as safras em ordem cronológica crescente de início (a mais
  /// antiga primeiro), para exibição sequencial no select.
  List<Safra> _ordenarSafrasSequencialmente(List<Safra> safras) {
    final ordenadas = List<Safra>.from(safras);
    ordenadas.sort((a, b) {
      final dataA = a.dataInicio ?? a.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB = b.dataInicio ?? b.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final comparacaoData = dataA.compareTo(dataB);
      if (comparacaoData != 0) {
        return comparacaoData;
      }
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return ordenadas;
  }

  /// Numera as safras sequencialmente (1, 2, 3...) a partir de uma lista já
  /// ordenada cronologicamente, independentemente do id do backend.
  Map<int, int> _numerarSafras(List<Safra> safrasOrdenadas) {
    final numeros = <int, int>{};
    for (var i = 0; i < safrasOrdenadas.length; i++) {
      final id = safrasOrdenadas[i].id;
      if (id != null) {
        numeros[id] = i + 1;
      }
    }
    return numeros;
  }

  /// Nome de exibição da safra: usa o nome cadastrado, se houver; senão
  /// cai no número sequencial ("Safra 1", "Safra 2"...).
  String _nomeExibicaoSafra(Safra safra, Map<int, int> numerosSafra) {
    if (safra.nome.isNotEmpty) {
      return safra.nome;
    }
    final numero = safra.id != null ? numerosSafra[safra.id] : null;
    return numero != null ? 'Safra $numero' : 'Safra ${safra.id ?? 'sem id'}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final propriedadesVm = context.watch<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVm.idPropriedadeSelecionada;

    if (idPropriedade != null && idPropriedade != _ultimaPropriedadeCarregada) {
      _ultimaPropriedadeCarregada = idPropriedade;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        context.read<SafraViewModel>().carregarDadosDaPropriedade(idPropriedade);
      });
    }
  }

  Future<void> _mostrarDialogoNovaSafra() async {
    DateTime? dataInicioSelecionada = DateTime.now();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nova safra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Defina a data de início da safra para registrar o ciclo.'),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final selecionada = await showDatePicker(
                    context: dialogContext,
                    initialDate: dataInicioSelecionada ?? DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (selecionada != null && dialogContext.mounted) {
                    dataInicioSelecionada = selecionada;
                    (dialogContext as Element?)?.markNeedsBuild();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF67835C)),
                      const SizedBox(width: 10),
                      Text(
                        dataInicioSelecionada == null
                            ? 'Selecionar data'
                            : '${dataInicioSelecionada!.day.toString().padLeft(2, '0')}/${dataInicioSelecionada!.month.toString().padLeft(2, '0')}/${dataInicioSelecionada!.year}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.save_outlined),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8FA67E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              label: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true && mounted) {
      final propriedadesVm = context.read<PropriedadesUsuarioViewModel>();
      final idPropriedade = propriedadesVm.idPropriedadeSelecionada;
      if (idPropriedade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma propriedade antes de cadastrar uma safra.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        final viewModel = context.read<SafraViewModel>();
        final sucesso = await viewModel.criarSafra(
          idPropriedade: idPropriedade,
          dataInicio: dataInicioSelecionada,
        );

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sucesso
                  ? 'Safra cadastrada com sucesso.'
                  : viewModel.mensagemErro ?? 'Não foi possível cadastrar a safra.',
            ),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _encerrarSafraSelecionada() async {
    final viewModel = context.read<SafraViewModel>();
    final safra = viewModel.safraSelecionada;

    if (safra == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma safra para encerrá-la.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (safra.isEncerrada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta safra já está encerrada.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    DateTime? dataFimSelecionada = DateTime.now();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Encerrar safra'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deseja encerrar a safra ${safra.nome.isNotEmpty ? safra.nome : 'selecionada'}?'),
                  const SizedBox(height: 12),
                  const Text('Data de fim da safra'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selecionada = await showDatePicker(
                        context: dialogContext,
                        initialDate: dataFimSelecionada ?? DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (selecionada != null) {
                        dataFimSelecionada = selecionada;
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF67835C)),
                          const SizedBox(width: 10),
                          Text(
                            '${dataFimSelecionada!.day.toString().padLeft(2, '0')}/${dataFimSelecionada!.month.toString().padLeft(2, '0')}/${dataFimSelecionada!.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Encerrar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    final propriedadesVm = context.read<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVm.idPropriedadeSelecionada;

    if (idPropriedade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível localizar a propriedade atual.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sucesso = await viewModel.encerrarSafra(
      idPropriedade: idPropriedade,
      idSafra: safra.id ?? 0,
      dataFim: dataFimSelecionada,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Safra encerrada com sucesso.'
              : viewModel.mensagemErro ?? 'Não foi possível encerrar a safra.',
        ),
        backgroundColor: sucesso ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SafraViewModel>();
    final propriedadesVm = context.watch<PropriedadesUsuarioViewModel>();

    String? nomePropriedade;
    for (final propriedade in propriedadesVm.propriedades) {
      if (propriedade.id == propriedadesVm.idPropriedadeSelecionada) {
        nomePropriedade = propriedade.nome;
        break;
      }
    }

    final safrasEmOrdem = _ordenarSafrasSequencialmente(viewModel.safras);
    final numerosSafra = _numerarSafras(safrasEmOrdem);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Safras e relatórios'),
        backgroundColor: const Color(0xFF8FA67E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (propriedadesVm.idPropriedadeSelecionada != null) {
            await viewModel.carregarDadosDaPropriedade(
              propriedadesVm.idPropriedadeSelecionada!,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleção da safra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF67835C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nomePropriedade ?? 'Selecione uma propriedade para ver as safras.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Safra>(
                        value: viewModel.safras.any((s) => s == viewModel.safraSelecionada)
                            ? viewModel.safraSelecionada
                            : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF67835C), width: 2),
                          ),
                          labelStyle: const TextStyle(color: Color(0xFF67835C)),
                          floatingLabelStyle: const TextStyle(color: Color(0xFF67835C)),
                          labelText: 'Safra selecionada',
                        ),
                        selectedItemBuilder: (context) {
                          return safrasEmOrdem.map((safra) {
                            final nomeSafra = _nomeExibicaoSafra(safra, numerosSafra);
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                safra.isEncerrada ? '$nomeSafra (Encerrada)' : nomeSafra,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                        },
                        items: safrasEmOrdem
                            .map(
                              (safra) => DropdownMenuItem<Safra>(
                                value: safra,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(_nomeExibicaoSafra(safra, numerosSafra)),
                                    ),
                                    if (safra.isEncerrada)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text('Encerrada', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      )
                                    else
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8FA67E).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text('Ativa', style: TextStyle(fontSize: 11, color: Color(0xFF67835C))),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: viewModel.safras.isEmpty
                            ? null
                            : (Safra? safra) {
                                if (safra != null) {
                                  viewModel.selecionarSafra(safra);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: viewModel.isLoading ? null : _mostrarDialogoNovaSafra,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Nova safra'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8FA67E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: viewModel.isLoading || viewModel.safraSelecionada == null || viewModel.safraSelecionada!.isEncerrada
                                  ? null
                                  : _encerrarSafraSelecionada,
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: const Text('Encerrar safra'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.mensagemErro != null)
                Center(
                  child: Column(
                    children: [
                      _buildMessageCard(viewModel.mensagemErro!),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          if (propriedadesVm.idPropriedadeSelecionada != null) {
                            viewModel.carregarDadosDaPropriedade(
                              propriedadesVm.idPropriedadeSelecionada!,
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              else if (viewModel.safras.isEmpty)
                _buildEmptyState()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.safraSelecionada != null)
                      _buildSafraSummary(viewModel.safraSelecionada!, numerosSafra),
                    const SizedBox(height: 16),
                    const Text(
                      'Relatório da safra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF67835C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.isLoadingRelatorio)
                      const Center(child: CircularProgressIndicator())
                    else if (viewModel.relatorio.isEmpty)
                      _buildEmptyReportState()
                    else
                      ...viewModel.relatorio.map(_buildEventCard).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafraSummary(Safra safra, Map<int, int> numerosSafra) {
    final statusTexto = safra.status.isNotEmpty ? safra.status : (safra.ativa ? 'Ativa' : 'Inativa');
    final isEncerrada = safra.isEncerrada;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _nomeExibicaoSafra(safra, numerosSafra),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isEncerrada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Encerrada', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(safra.periodoTexto),
            const SizedBox(height: 4),
            Text('Status: $statusTexto'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(SafraEvento evento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento.descricao.isNotEmpty ? evento.descricao : 'Evento da safra',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (evento.tipo.isNotEmpty)
              Text('Tipo: ${evento.tipo}'),
            if (evento.data.isNotEmpty)
              Text('Data: ${evento.data}'),
            if (evento.status.isNotEmpty)
              Text('Status: ${evento.status}'),
            if (evento.responsavel.isNotEmpty)
              Text('Responsável: ${evento.responsavel}'),
            if (evento.valor.isNotEmpty)
              Text('Valor: ${evento.valor}'),
            if (evento.quantidade.isNotEmpty)
              Text('Quantidade: ${evento.quantidade}'),
            if (evento.observacao.isNotEmpty)
              Text('Observação: ${evento.observacao}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.grass, size: 44, color: Color(0xFF8FA67E)),
              const SizedBox(height: 12),
              const Text('Nenhuma safra cadastrada ativa para esta propriedade.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyReportState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.description_outlined, size: 44, color: Color(0xFF8FA67E)),
              const SizedBox(height: 12),
              const Text(
                'Nada registrado nessa Safra ainda, registre mais dados e os relatórios aparecerão por aqui!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}