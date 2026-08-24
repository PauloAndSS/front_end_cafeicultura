import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/main_screen_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/custom_bottom_navbar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_summary.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data_em_bloco.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

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

  static DateTime get _pisoDeSafra => DateTime(DateTime.now().year - 1);
  static DateTime get _tetoDeSafra => DateTime(DateTime.now().year + 5, 12, 31);

  Future<void> _mostrarDialogoNovaSafra() async {
    final hoje = DateTime.now();
    DateTime dataInicioSelecionada = DateTime(hoje.year, hoje.month, hoje.day);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialogo) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Nova safra'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Defina a data de início da safra para registrar o ciclo.'),
                  const SizedBox(height: 12),
                  SeletorDataEmBloco(
                    data: dataInicioSelecionada,
                    aoTocar: () async {
                      final selecionada = await selecionarData(
                        context: dialogContext,
                        ajuda: 'Selecione a data de início da safra',
                        inicial: dataInicioSelecionada,
                        minima: _pisoDeSafra,
                        maxima: _tetoDeSafra,
                      );
                      if (selecionada != null) {
                        setStateDialogo(
                          () => dataInicioSelecionada = selecionada,
                        );
                      }
                    },
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
                    backgroundColor: AppCores.verdeSecundario,
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
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    final propriedadesVm = context.read<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVm.idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarAviso(context, 'Selecione uma propriedade antes de cadastrar uma safra.');
      return;
    }

    final viewModel = context.read<SafraViewModel>();
    final sucesso = await viewModel.criarSafra(
      idPropriedade: idPropriedade,
      dataInicio: dataInicioSelecionada,
    );

    if (!mounted) {
      return;
    }

    mostrarResultado(context, sucesso
              ? 'Safra cadastrada com sucesso.'
              : viewModel.mensagemErro ?? 'Não foi possível cadastrar a safra.', sucesso: sucesso);
  }

  Future<void> _encerrarSafraSelecionada() async {
    final viewModel = context.read<SafraViewModel>();
    final safra = viewModel.safraSelecionada;

    if (safra == null) {
      mostrarAviso(context, 'Selecione uma safra para encerrá-la.');
      return;
    }

    if (safra.encerrada) {
      mostrarAviso(context, 'Esta safra já está encerrada.');
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
                  const CaixaAvisoAtencao(
                    mensagem:
                        'Após o encerramento, nenhum dado dessa safra poderá '
                        'ser alterado. Ela ficará "congelada" até que seja '
                        'reativada.',
                  ),
                  const SizedBox(height: 12),
                  const Text('Data de fim da safra'),
                  const SizedBox(height: 8),
                  SeletorDataEmBloco(
                    data: dataFimSelecionada!,
                    aoTocar: () async {
                      final selecionada = await selecionarData(
                        context: dialogContext,
                        ajuda: 'Selecione a data de fim da safra',
                        inicial: dataFimSelecionada,
                        minima: _pisoDeSafra,
                        maxima: _tetoDeSafra,
                      );
                      if (selecionada != null) {
                        dataFimSelecionada = selecionada;
                        setState(() {});
                      }
                    },
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
      mostrarErro(context, 'Não foi possível localizar a propriedade atual.');
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

    mostrarResultado(context, sucesso
              ? 'Safra encerrada com sucesso.'
              : viewModel.mensagemErro ?? 'Não foi possível encerrar a safra.', sucesso: sucesso);
  }

  Future<void> _reativarSafraSelecionada() async {
    final viewModel = context.read<SafraViewModel>();
    final safra = viewModel.safraSelecionada;

    if (safra == null) {
      mostrarAviso(context, 'Selecione uma safra para reativá-la.');
      return;
    }

    if (!safra.encerrada) {
      mostrarAviso(context, 'Esta safra já está ativa.');
      return;
    }

    final nomeSafraDialogo = safra.nomeExibicao;

    final confirmar = await confirmarAcao(
      context,
      titulo: 'Reativar safra',
      mensagem:
          'Deseja reativar a $nomeSafraDialogo? Os dados voltarão a poder ser '
          'editados normalmente.',
      rotuloConfirmar: 'Reativar',
      corConfirmar: AppCores.verdeSecundario,
    );

    if (!confirmar || !mounted) {
      return;
    }

    final propriedadesVm = context.read<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVm.idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarErro(context, 'Não foi possível localizar a propriedade atual.');
      return;
    }

    final sucesso = await viewModel.reativarSafra(
      idPropriedade: idPropriedade,
      idSafra: safra.id ?? 0,
    );

    if (!mounted) {
      return;
    }

    mostrarResultado(context, sucesso
              ? 'Safra reativada com sucesso.'
              : viewModel.mensagemErro ?? 'Não foi possível reativar a safra.', sucesso: sucesso);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SafraViewModel>();
    final propriedadesVm = context.watch<PropriedadesUsuarioViewModel>();

    final nomePropriedade = propriedadesVm.propriedadeSelecionada?.nome;

    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBarPadrao(
        titulo: 'Safras',
        cor: AppCores.verdeSecundario,
        elevacao: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: _voltar,
        ),
      ),
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
                        CartaoDeErro(mensagem: viewModel.mensagemErro!),
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
                  child: const CartaoVazio(
                    icone: Icons.grass,
                    mensagem:
                        'Nenhuma safra cadastrada ativa para esta propriedade.',
                  ),
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
              const Icon(Icons.dashboard_outlined, size: 20, color: AppCores.verdePrimario),
              const SizedBox(width: 8),
              Text(
                viewModel.safraSelecionada != null
                    ? 'Resumo de ${viewModel.safraSelecionada!.nomeExibicao}'
                    : 'Resumo da safra',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.verdePrimario),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.safraSelecionada != null) SafraSummaryCard(safra: viewModel.safraSelecionada!),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}
