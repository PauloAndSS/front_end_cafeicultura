import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/model_cotacao_cafe.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/cotacao_cafe_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';

class CotacaoCafeWidget extends StatefulWidget {
  final CotacaoCafeViewModel viewModel;

  const CotacaoCafeWidget({super.key, required this.viewModel});

  @override
  State<CotacaoCafeWidget> createState() => _CotacaoCafeWidgetState();
}

class _CotacaoCafeWidgetState extends State<CotacaoCafeWidget> {
  final PageController _controladorDePagina = PageController();
  int _paginaAtual = 0;
  static const int _totalDePaginas = 3;

  @override
  void dispose() {
    _controladorDePagina.dispose();
    super.dispose();
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: child,
      ),
    );
  }

  Widget _buildConteudo(RespostaCotacaoCafe resposta) {
    return Column(
      key: const ValueKey('conteudo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCabecalho(resposta),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
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
        const SizedBox(height: 10),
        _buildIndicadorDePagina(),
      ],
    );
  }

  Widget _buildCabecalho(RespostaCotacaoCafe resposta) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppCores.verdePrimario.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.coffee_rounded, size: 20, color: AppCores.verdePrimario),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cotação do Café',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppCores.verdePrimario,
                ),
              ),
              if (resposta.dataColeta != null)
                Text(
                  'Atualizado em ${_formatarDataHora(resposta.dataColeta!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildPaginaPainel(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDoPainel) {
      return _buildFonteIndisponivel(
        fonte: 'Painel do Café',
        mensagem: 'Cotação indisponível para esta fonte.',
      );
    }
    return _buildCotacao(fonte: 'Painel do Café', item: resposta.painelDoCafe.first);
  }


  Widget _buildPaginaCooabriel(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDaCooabriel) {
      final erro = resposta.erros.isNotEmpty
          ? resposta.erros.first
          : 'Cotação indisponível para esta fonte.';
      return _buildFonteIndisponivel(fonte: 'Cooabriel', mensagem: erro);
    }

    final itensDeCafe = _apenasCafe(resposta.cooabriel!);
    if (itensDeCafe.isEmpty) {
      return _buildFonteIndisponivel(
        fonte: 'Cooabriel',
        mensagem: 'Cotação indisponível para esta fonte.',
      );
    }

    return _buildTabelaCooabriel(itensDeCafe);
  }

  Widget _buildPaginaCccv(RespostaCotacaoCafe resposta) {
    if (!resposta.temDadosDaCccv) {
      return _buildFonteIndisponivel(
        fonte: 'CCCV',
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

  Widget _buildTabelaCooabriel(List<ItemCooabriel> itens) {
    final primeiro = itens.first;
    final dataHora = primeiro.data.isNotEmpty
        ? '${primeiro.data} às ${primeiro.hora}'
        : null;

    return Container(
      key: const ValueKey('cooabriel-tabela'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppCores.fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRotuloDaFonte('Cooabriel'),
          if (dataHora != null) ...[
            const SizedBox(height: 8),
            _buildAvisoUltimaCotacao(dataHora),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: itens.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, i) {
                final item = itens[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.tipo,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.preco,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppCores.verdeSecundario,
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

  Widget _buildTabelaCccv(CccvCotacao cccv) {
    final linhas = <(String, double, double)>[
      ('Arábica Dura', cccv.cotacaoDia.arabicaDura, cccv.mediaMensal.arabicaDura),
      ('Arábica Rio', cccv.cotacaoDia.arabicaRio, cccv.mediaMensal.arabicaRio),
      ('Conilon', cccv.cotacaoDia.conilon, cccv.mediaMensal.conilon),
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
          _buildRotuloDaFonte('CCCV'),
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
                    color: Colors.black45,
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
                    color: Colors.black45,
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
              separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.black12),
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
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatarMoeda(hoje),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppCores.verdeSecundario,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatarMoeda(mensal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppCores.verdePrimario.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppCores.verdePrimario),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Última cotação publicada em $dataHora',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCotacao({required String fonte, required ItemCotacaoCafe item}) {
    return Container(
      key: ValueKey('cotacao-$fonte-${item.nome}'),
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
          const SizedBox(height: 10),
          Text(
            item.nome,
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatarMoeda(item.valor),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppCores.verdeSecundario,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('/ saca', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFonteIndisponivel({required String fonte, required String mensagem}) {
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
              const Icon(Icons.error_outline_rounded, size: 18, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(mensagem, style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
        const Icon(Icons.storefront_rounded, size: 14, color: Colors.black45),
        const SizedBox(width: 6),
        Text(
          fonte.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
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
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.coffee_rounded, size: 20, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cotação do Café',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppCores.verdePrimario),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 20, color: Colors.redAccent),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Serviço indisponível',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildIndicadorDePagina() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalDePaginas, (index) {
        final ativa = index == _paginaAtual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: ativa ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: ativa ? AppCores.verdeSecundario : Colors.black12,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}


String _formatarMoeda(double valor) {
  final fixo = valor.toStringAsFixed(2);
  final partes = fixo.split('.');
  final parteInteira = partes[0];
  final parteDecimal = partes[1];

  final buffer = StringBuffer();
  for (int i = 0; i < parteInteira.length; i++) {
    final posicaoDoFim = parteInteira.length - i;
    if (i > 0 && posicaoDoFim % 3 == 0) buffer.write('.');
    buffer.write(parteInteira[i]);
  }
  return 'R\$ ${buffer.toString()},$parteDecimal';
}

String _formatarDataHora(DateTime dt) {
  final local = dt.toLocal();
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year} às '
      '${dois(local.hour)}:${dois(local.minute)}';
}