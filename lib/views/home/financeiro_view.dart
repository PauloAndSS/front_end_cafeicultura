import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/financeiro/financeiro_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/detalhes_despesa_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/transacao_financeira_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/relatorio_financeiro_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/safra_selector.dart';
import 'package:provider/provider.dart';

class FinanceiroView extends StatefulWidget {
  const FinanceiroView({super.key});

  @override
  State<FinanceiroView> createState() => _FinanceiroViewState();
}

class _FinanceiroViewState extends State<FinanceiroView> {
  static const int _incrementoExibicao = 3;

  int _quantidadeDespesasExibidas = _incrementoExibicao;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizarDados());
  }

  void _sincronizarDados() {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    final safraVM = context.read<SafraViewModel>();
    final financeiroVM = context.read<FinanceiroViewModel>();

    final idPropriedade = propriedadesVM.idPropriedadeSelecionada;
    if (idPropriedade == null) return;

    safraVM.carregarDadosDaPropriedade(idPropriedade).then((_) {
      final idSafra = safraVM.safraSelecionada?.id;
      if (idSafra != null) {
        financeiroVM.carregarRelatorio(
          idPropriedade: idPropriedade,
          idSafra: idSafra,
        );
      }
    });
  }

  Future<void> _lancarDespesa() async {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    final financeiroVM = context.read<FinanceiroViewModel>();
    final safraVM = context.read<SafraViewModel>();

    final idPropriedade = propriedadesVM.idPropriedadeSelecionada;
    final idSafra = safraVM.safraSelecionada?.id;

    if (idPropriedade == null || idSafra == null) {
      mostrarErro(context, 'Selecione uma propriedade e uma safra ativa.');
      return;
    }

    final despesa = await mostrarCadastroTransacao(
      context: context,
      idPropriedade: idPropriedade,
      catalogoDePessoas: financeiroVM,
    );

    if (despesa == null || !mounted) return;

    final sucesso = await financeiroVM.cadastrarDespesa(despesa);
    if (sucesso && mounted) {
      mostrarSucesso(context, 'Despesa lançada com sucesso!');
      // Rede de segurança: garante o refresh mesmo se notificarSeVivo() não disparar.
      financeiroVM.carregarRelatorio(
        idPropriedade: idPropriedade,
        idSafra: idSafra,
        emSegundoPlano: true,
      );
    }
  }

  Future<void> _verDetalhes(Despesa despesa) async {
    final financeiroVM = context.read<FinanceiroViewModel>();
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    final safraVM = context.read<SafraViewModel>();

    final excluir = await mostrarDetalhesDespesa(
      context: context,
      despesa: despesa,
      podeExcluir: despesa.id != null,
    );

    if (excluir == true && mounted) {
      final sucesso = await financeiroVM.excluirDespesa(despesa.id!);
      if (sucesso && mounted) {
        mostrarSucesso(context, 'Despesa excluída com sucesso!');
        final idPropriedade = propriedadesVM.idPropriedadeSelecionada;
        final idSafra = safraVM.safraSelecionada?.id;
        if (idPropriedade != null && idSafra != null) {
          // Rede de segurança: garante o refresh mesmo se notificarSeVivo() não disparar.
          financeiroVM.carregarRelatorio(
            idPropriedade: idPropriedade,
            idSafra: idSafra,
            emSegundoPlano: true,
          );
        }
      }
    }
  }

  Widget _buildDespesaCard(Despesa despesa) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CartaoEntidade(
        icone: Icons.payments_outlined,
        titulo: despesa.descricaoTexto,
        acao: BadgeTexto(
          texto: despesa.formaPagamento.rotulo,
          cor: AppCores.verdeSecundario,
        ),
        corpo: [
          LinhaCartao(
            icone: Icons.person_outline,
            titulo: 'Beneficiado',
            valor: despesa.beneficiadoTexto,
          ),
          const SizedBox(height: 8),
          LinhaCartao(
            icone: Icons.calendar_today_outlined,
            titulo: 'Data',
            valor: despesa.dataHoraFormatada ?? 'N/A',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              despesa.valorFormatado,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppCores.erro,
              ),
            ),
          ),
        ],
        onTap: () => _verDetalhes(despesa),
      ),
    );
  }

  List<Widget> _buildFilhosHistorico(FinanceiroViewModel financeiroVM) {
    final despesas = financeiroVM.despesas;

    if (despesas.isEmpty && !financeiroVM.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Nenhuma despesa encontrada.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }

    final quantidadeExibida = _quantidadeDespesasExibidas.clamp(0, despesas.length);
    final despesasExibidas = despesas.take(quantidadeExibida);
    final temMaisParaExibir = quantidadeExibida < despesas.length;

    return [
      ...despesasExibidas.map(_buildDespesaCard),
      if (temMaisParaExibir) _buildBotaoExibirMais(despesas.length - quantidadeExibida),
    ];
  }

  Widget _buildBotaoExibirMais(int quantidadeRestante) {
    final proximoIncremento = quantidadeRestante < _incrementoExibicao
        ? quantidadeRestante
        : _incrementoExibicao;

    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _quantidadeDespesasExibidas += _incrementoExibicao;
          });
        },
        icon: const Icon(Icons.expand_more, color: AppCores.verdePrimario),
        label: Text(
          'Exibir mais $proximoIncremento',
          style: const TextStyle(color: AppCores.verdePrimario),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final safraVM = context.watch<SafraViewModel>();
    final financeiroVM = context.watch<FinanceiroViewModel>();

    final idPropriedade = propriedadesVM.idPropriedadeSelecionada;
    final safraSelecionada = safraVM.safraSelecionada;

    return Scaffold(
      body: CorpoComEstado(
        isLoading: propriedadesVM.isLoading || safraVM.isLoading,
        mensagemErro: propriedadesVM.mensagemErro ?? safraVM.mensagemErro,
        vazio: false,
        construirVazio: (context) => const SizedBox.shrink(),
        aoTentarNovamente: _sincronizarDados,
        construirConteudo: (context) {
          return RefreshIndicator(
            onRefresh: () async => _sincronizarDados(),
            child: CustomScrollView(
              slivers: [
                if (idPropriedade != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: SafraSelectorWidget(
                        safras: safraVM.safras,
                        safraSelecionada: safraSelecionada,
                        // Desabilita botões de ação para evitar o erro de asserção
                        mostrarAcoes: false,
                        onSelecionar: (safra) {
                          if (safra.id != null) {
                            setState(() {
                              _quantidadeDespesasExibidas = _incrementoExibicao;
                            });
                            financeiroVM.carregarRelatorio(
                              idPropriedade: idPropriedade,
                              idSafra: safra.id!,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                if (safraSelecionada != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RelatorioFinanceiroWidget(
                        relatorio: financeiroVM.relatorio,
                        isLoading: financeiroVM.isLoading,
                        mensagemErro: financeiroVM.mensagemErro,
                        mostrarTitulo: true,
                        mostrarListaDespesas: false,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          key: const PageStorageKey('historico_despesas'),
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(top: 8),
                          iconColor: AppCores.verdePrimario,
                          collapsedIconColor: AppCores.verdePrimario,
                          title: const Text(
                            'Histórico de Despesas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          children: _buildFilhosHistorico(financeiroVM),
                        ),
                      ),
                    ),
                  ),
                ] else if (idPropriedade != null && !safraVM.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Cadastre uma safra para gerenciar o financeiro.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: idPropriedade != null && safraSelecionada != null
          ? FloatingActionButton(
              onPressed: _lancarDespesa,
              backgroundColor: AppCores.verdePrimario,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}