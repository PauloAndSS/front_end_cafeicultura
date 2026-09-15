import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/model_cotacao_cafe.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/cotacao_cafe_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';

const _intervaloDoAvanco = Duration(seconds: 6);

const _fontes = ['Painel do Café', 'Cooabriel', 'CCCV'];

class CotacaoCafeWidget extends StatefulWidget {
  final CotacaoCafeViewModel viewModel;

  const CotacaoCafeWidget({super.key, required this.viewModel});

  @override
  State<CotacaoCafeWidget> createState() => _CotacaoCafeWidgetState();
}

class _CotacaoCafeWidgetState extends State<CotacaoCafeWidget> {
  final PageController _controladorDePagina = PageController();
  int _paginaAtual = 0;
  Timer? _avancoAutomatico;

  @override
  void dispose() {
    _avancoAutomatico?.cancel();
    _controladorDePagina.dispose();
    super.dispose();
  }

  void _agendarAvanco() {
    if (_avancoAutomatico != null) return;
    if (MediaQuery.disableAnimationsOf(context)) return;

    _avancoAutomatico = Timer.periodic(_intervaloDoAvanco, (_) {
      if (!mounted || !_controladorDePagina.hasClients) return;

      _controladorDePagina.animateToPage(
        (_paginaAtual + 1) % _fontes.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _reiniciarAvanco() {
    _avancoAutomatico?.cancel();
    _avancoAutomatico = null;
    _agendarAvanco();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return CorpoComEstado(
      isLoading: vm.isLoading,
      mensagemErro: vm.mensagemErro,
      aoTentarNovamente: () => vm.carregar(),
      vazio: !vm.temDados,
      construirVazio: (_) => _buildCard(child: _buildIndisponivelGeral()),
      construirConteudo: (_) => _buildCard(child: _buildConteudo(vm.resposta!)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: AppEstilos.cartao(),
      child: child,
    );
  }

  Widget _buildConteudo(RespostaCotacaoCafe resposta) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _agendarAvanco();
    });

    return Column(
      key: const ValueKey('conteudo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCabecalho(resposta),
        const SizedBox(height: 14),
        SizedBox(
          height: 250,
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (aviso) {
              if (aviso.dragDetails != null) _reiniciarAvanco();
              return false;
            },
            child: PageView(
              controller: _controladorDePagina,
              onPageChanged: (i) => setState(() => _paginaAtual = i),
              children: [
                _buildPaginaPainel(resposta),
                _buildPaginaCooabriel(resposta),
                _buildPaginaCccv(resposta),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicadorDeFonte(),
      ],
    );
  }

  Widget _buildCabecalho(RespostaCotacaoCafe resposta) {
    final coletadoEm = resposta.coletadoEmFormatado;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppCores.acao.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.coffee_rounded,
            size: 20,
            color: AppCores.acao,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cotação do Café',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppCores.acao,
                ),
              ),
              if (coletadoEm != null)
                Text(
                  'Atualizado em $coletadoEm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppCores.textoSecundario,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicadorDeFonte() {
    return Semantics(
      container: true,
      label:
          'Fonte ${_paginaAtual + 1} de ${_fontes.length}: '
          '${_fontes[_paginaAtual]}. Arraste para ver as outras.',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _fontes.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _paginaAtual ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _paginaAtual
                      ? AppCores.acao
                      : AppCores.bordaCampo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginaPainel(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDoPainel || resposta.painelDoCafe.isEmpty) {
      return _buildFonteIndisponivel(
        fonte: _fontes[0],
        mensagem: 'Cotação indisponível para esta fonte.',
      );
    }

    return _buildPainelDeCotacoes(
      chave: 'painel',
      fonte: _fontes[0],
      publicadoEm: null,
      linhas: [
        for (final item in resposta.painelDoCafe)
          (nome: item.nome, preco: item.valorFormatado),
      ],
    );
  }

  Widget _buildPaginaCooabriel(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDaCooabriel) {
      final erro = resposta.erros.isNotEmpty
          ? resposta.erros.first
          : 'Cotação indisponível para esta fonte.';
      return _buildFonteIndisponivel(fonte: _fontes[1], mensagem: erro);
    }

    final itensDeCafe = _apenasCafe(resposta.cooabriel!);
    if (itensDeCafe.isEmpty) {
      return _buildFonteIndisponivel(
        fonte: _fontes[1],
        mensagem: 'Cotação indisponível para esta fonte.',
      );
    }

    return _buildPainelDeCotacoes(
      chave: 'cooabriel',
      fonte: _fontes[1],
      publicadoEm: itensDeCafe.first.publicadoEm,
      linhas: [
        for (final item in itensDeCafe)
          (nome: item.tipo, preco: item.precoFormatado),
      ],
    );
  }

  Widget _buildPaginaCccv(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDaCccv) {
      return _buildFonteIndisponivel(
        fonte: _fontes[2],
        mensagem: 'Cotação indisponível para esta fonte.',
      );
    }

    return _buildTabelaCccv(resposta.cccv!);
  }

  List<ItemCooabriel> _apenasCafe(List<ItemCooabriel> itens) {
    return itens
        .where((item) => !item.tipo.toLowerCase().contains('pimenta'))
        .toList();
  }

  Widget _buildPainelDeCotacoes({
    required String chave,
    required String fonte,
    required String? publicadoEm,
    required List<({String nome, String preco})> linhas,
  }) {
    final destaque = linhas.first;
    final demais = linhas.skip(1).toList();

    return Container(
      key: ValueKey(chave),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppCores.fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRotuloDaFonte(fonte),
          const SizedBox(height: 10),
          Text(
            destaque.nome,
            style: const TextStyle(
              fontSize: 14,
              color: AppCores.textoPrimario,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                destaque.preco,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppCores.acao,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ saca de 60 kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppCores.textoSecundario,
                  ),
                ),
              ),
            ],
          ),
          if (demais.isNotEmpty) ...[
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    for (var i = 0; i < demais.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, color: AppCores.borda),
                      _buildLinha(demais[i]),
                    ],
                  ],
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (publicadoEm != null) _buildAvisoUltimaCotacao(publicadoEm),
        ],
      ),
    );
  }

  Widget _buildLinha(({String nome, String preco}) linha) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              linha.nome,
              style: const TextStyle(
                fontSize: 13,
                color: AppCores.textoPrimario,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            linha.preco,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppCores.acao,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabelaCccv(CccvCotacao cccv) {
    final dia = cccv.cotacaoDia;
    final mes = cccv.mediaMensal;
    final linhas = <(String, String, String)>[
      ('Arábica Dura', dia.arabicaDuraFormatado, mes.arabicaDuraFormatado),
      ('Arábica Rio', dia.arabicaRioFormatado, mes.arabicaRioFormatado),
      ('Conilon', dia.conilonFormatado, mes.conilonFormatado),
    ];
    final rotuloHoje = cccv.cotacaoDia.dia != null
        ? 'Hoje (dia ${cccv.cotacaoDia.dia})'
        : 'Hoje';

    return Container(
      key: const ValueKey('cccv-tabela'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppCores.fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRotuloDaFonte(_fontes[2]),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Text(
                  rotuloHoje,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppCores.textoTerciario,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text(
                  'Média mensal',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppCores.textoTerciario,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: linhas.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppCores.borda),
              itemBuilder: (context, i) {
                final (nome, hoje, mensal) = linhas[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          nome,
                          style: const TextStyle(fontSize: 13, color: AppCores.textoPrimario),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          hoje,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppCores.acao,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          mensal,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, color: AppCores.textoSecundario),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoUltimaCotacao(String dataHora) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: AppCores.textoTerciario,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Publicada em $dataHora',
              style: const TextStyle(
                fontSize: 11,
                color: AppCores.textoTerciario,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFonteIndisponivel({
    required String fonte,
    required String mensagem,
  }) {
    return Container(
      key: ValueKey('indisponivel-$fonte'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppCores.fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRotuloDaFonte(fonte),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: AppCores.erro,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensagem,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppCores.textoSecundario,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRotuloDaFonte(String fonte) {
    return Row(
      children: [
        const Icon(
          Icons.storefront_rounded,
          size: 14,
          color: AppCores.textoSecundario,
        ),
        const SizedBox(width: 6),
        Text(
          fonte.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: AppCores.textoSecundario,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIndisponivelGeral() {
    return Column(
      key: const ValueKey('indisponivel-geral'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppCores.erro.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.coffee_rounded,
                size: 20,
                color: AppCores.erro,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Cotação do Café',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppCores.acao,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 20,
              color: AppCores.erro,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Serviço indisponível',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppCores.textoPrimario,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
