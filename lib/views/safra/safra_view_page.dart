import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/main_screen_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_summary.dart';
import 'package:provider/provider.dart';


class SafraViewPage extends StatefulWidget {
  const SafraViewPage({super.key});

  @override
  State<SafraViewPage> createState() => _SafraViewPageState();
}

class _SafraViewPageState extends State<SafraViewPage> {
  int? _ultimaPropriedadeCarregada;

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


void _voltar() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context, true); 
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreenView()),
        (route) => false,
      );
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
    final nomeSafraDialogo = safra.nomeExibicao;

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
                  Text('Deseja encerrar a $nomeSafraDialogo?'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Após o encerramento, nenhum dado dessa safra poderá ser alterado. '
                            'Ela ficará "congelada" até que seja reativada.',
                            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Future<void> _reativarSafraSelecionada() async {
    final viewModel = context.read<SafraViewModel>();
    final safra = viewModel.safraSelecionada;

    if (safra == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma safra para reativá-la.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!safra.isEncerrada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta safra já está ativa.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nomeSafraDialogo = safra.nomeExibicao;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reativar safra'),
          content: Text(
            'Deseja reativar a $nomeSafraDialogo? Os dados voltarão a poder ser editados normalmente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8FA67E)),
              child: const Text('Reativar'),
            ),
          ],
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

    final sucesso = await viewModel.reativarSafra(
      idPropriedade: idPropriedade,
      idSafra: safra.id ?? 0,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Safra reativada com sucesso.'
              : viewModel.mensagemErro ?? 'Não foi possível reativar a safra.',
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: _voltar,
        ),
        title: const Text('Safras'),
        backgroundColor: const Color(0xFF8FA67E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 👇 ADICIONADO AQUI:
      bottomNavigationBar: const CustomBottomNavBar(ocultarSelecao: true),
      body: RefreshIndicator(
        onRefresh: () async {
          if (propriedadesVm.idPropriedadeSelecionada != null) {
            await viewModel.carregarDadosDaPropriedade(
              propriedadesVm.idPropriedadeSelecionada!,
              forcarAtualizacao: true,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área de gestão da safra: seleção + ações de
              // nova/encerrar/reativar.
              Padding(
                padding: const EdgeInsets.all(16),
                child: SafraSelectorWidget(
                  titulo: 'Seleção da safra',
                  subtitulo: nomePropriedade ?? 'Selecione uma propriedade para ver as safras.',
                  safras: viewModel.safras,
                  safraSelecionada: viewModel.safraSelecionada,
                  isLoading: viewModel.isLoading,
                  onSelecionar: (Safra safra) => viewModel.selecionarSafra(safra),
                  onNovaSafra: _mostrarDialogoNovaSafra,
                  onEncerrarSafra: _encerrarSafraSelecionada,
                  onReativarSafra: _reativarSafraSelecionada,
                ),
              ),
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (viewModel.mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Column(
                      children: [
                        _buildMessageCard(viewModel.mensagemErro!),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            if (propriedadesVm.idPropriedadeSelecionada != null) {
                              viewModel.carregarDadosDaPropriedade(
                                propriedadesVm.idPropriedadeSelecionada!,
                                forcarAtualizacao: true,
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                )
              else if (viewModel.safras.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildEmptyState(),
                )
              else 
                 _buildDashboardDaSafra(viewModel),

              ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardDaSafra(SafraViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_outlined, size: 20, color: Color(0xFF67835C)),
              const SizedBox(width: 8),
              Text(
                viewModel.safraSelecionada != null
                    ? 'Dashboard de ${viewModel.safraSelecionada!.nomeExibicao}'
                    : 'Dashboard da safra',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF67835C)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.safraSelecionada != null) SafraSummaryCard(safra: viewModel.safraSelecionada!),
          const SizedBox(height: 16),
          /*SafraRelatorioWidget(
            eventos: viewModel.relatorio,
            isLoading: viewModel.isLoadingRelatorio,
          ),*/
        ],
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
}