import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/safra/pie_chart.dart';

class RelatorioFinanceiroWidget extends StatefulWidget {
  final int? idPropriedade;
  final int? idSafra;
  final RelatorioFinanceiroSafra? relatorio;
  final bool isLoading;
  final String? mensagemErro;
  final bool mostrarTitulo;
  final bool mostrarListaDespesas;

  const RelatorioFinanceiroWidget({
    super.key,
    this.idPropriedade,
    this.idSafra,
    this.relatorio,
    this.isLoading = false,
    this.mensagemErro,
    this.mostrarTitulo = true,
    this.mostrarListaDespesas = true,
  });

  @override
  State<RelatorioFinanceiroWidget> createState() =>
      _RelatorioFinanceiroWidgetState();
}

class _RelatorioFinanceiroWidgetState extends State<RelatorioFinanceiroWidget> {
  final ServicesSafra _service = ServicesSafra();

  bool _carregandoLocal = false;
  String? _erroLocal;
  RelatorioFinanceiroSafra? _relatorioLocal;

  static const List<Color> _paletaGastos = AppCores.paletaVerde;

  bool get _usarDadosExternos => widget.relatorio != null;

  RelatorioFinanceiroSafra get _relatorioAtual =>
      widget.relatorio ?? _relatorioLocal ?? RelatorioFinanceiroSafra.vazio;

  bool get _estaCarregando =>
      _usarDadosExternos ? widget.isLoading : _carregandoLocal;

  String? get _erroAtual => _usarDadosExternos ? widget.mensagemErro : _erroLocal;

  @override
  void initState() {
    super.initState();
    if (!_usarDadosExternos &&
        widget.idPropriedade != null &&
        widget.idSafra != null) {
      _carregar();
    }
  }

  @override
  void didUpdateWidget(covariant RelatorioFinanceiroWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_usarDadosExternos &&
        (oldWidget.idPropriedade != widget.idPropriedade ||
            oldWidget.idSafra != widget.idSafra) &&
        widget.idPropriedade != null &&
        widget.idSafra != null) {
      _carregar();
    }
  }

  Future<void> _carregar() async {
    if (widget.idPropriedade == null || widget.idSafra == null) return;

    setState(() {
      _carregandoLocal = true;
      _erroLocal = null;
    });

    try {
      final relatorio = await _service.buscarRelatorioFinanceiro(
        idPropriedade: widget.idPropriedade!,
        idSafra: widget.idSafra!,
      );
      if (!mounted) return;
      setState(() => _relatorioLocal = relatorio);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erroLocal = e.mensagem);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroLocal = 'Erro ao carregar o relatório financeiro.');
    } finally {
      if (mounted) setState(() => _carregandoLocal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget conteudo;

    if (_estaCarregando) {
      conteudo = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppCores.verdePrimario),
        ),
      );
    } else if (_erroAtual != null) {
      conteudo = Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _erroAtual!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              if (!_usarDadosExternos) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _carregar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      );
    } else if (_relatorioAtual.transacoes.isEmpty) {
      conteudo = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.payments_outlined, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Nenhuma despesa registrada nessa safra ainda.',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      conteudo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumo(_relatorioAtual),
          const SizedBox(height: 12),
          _buildGraficoPorDescricao(_relatorioAtual),
          if (widget.mostrarListaDespesas) ...[
            const SizedBox(height: 16),
            _buildListaDeDespesas(_relatorioAtual),
          ],
        ],
      );
    }

    if (!widget.mostrarTitulo) {
      return conteudo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.monetization_on_outlined, size: 20, color: AppCores.verdePrimario),
            SizedBox(width: 8),
            Text(
              'Relatório Financeiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        conteudo,
      ],
    );
  }

  Widget _buildResumo(RelatorioFinanceiroSafra relatorio) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, size: 20, color: AppCores.verdePrimario),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Custo total da safra',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppCores.verdePrimario,
                ),
              ),
            ),
            Text(
              formatarMoeda(relatorio.custoTotal),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoPorDescricao(RelatorioFinanceiroSafra relatorio) {
    final totais = _agruparPorDescricaoNormalizada(relatorio.totalPorDescricao);
    if (totais.isEmpty) return const SizedBox.shrink();

    // Converte os valores em reais para centavos inteiros para uso no PieChartCard
    final valoresEmCentavos = totais.map(
      (chave, valor) => MapEntry(chave, (valor * 100).round()),
    );

    return PieChartCard(
      titulo: 'Gastos por descrição',
      icone: Icons.pie_chart_outline,
      valores: valoresEmCentavos,
      paleta: _paletaGastos,
      valorFormatador: (centavos) => formatarMoeda(centavos / 100),
    );
  }

  /// Reúne descrições equivalentes (ex: "diaria", "Diaria", "Pagamento de
  /// diaria") em uma única categoria, somando os valores e escolhendo um
  /// rótulo legível para exibição no gráfico.
  Map<String, num> _agruparPorDescricaoNormalizada(Map<String, num> totais) {
    final Map<String, _GrupoDescricao> grupos = {};

    totais.forEach((descricaoOriginal, valor) {
      final chave = _normalizarDescricao(descricaoOriginal);
      if (chave.isEmpty) return;

      final grupo = grupos.putIfAbsent(
        chave,
        () => _GrupoDescricao(rotulo: _capitalizar(chave)),
      );
      grupo.total += valor;
    });

    return {for (final grupo in grupos.values) grupo.rotulo: grupo.total};
  }

  /// Normaliza uma descrição de despesa para fins de agrupamento:
  /// remove espaços nas pontas, acentos, caixa e prefixos comuns
  /// (ex: "pagamento de ", "referente a ") que não mudam a categoria.
  String _normalizarDescricao(String texto) {
    var normalizado = _removerAcentos(texto.trim().toLowerCase());

    const prefixosParaRemover = [
      'pagamento de ',
      'pagamento da ',
      'pagamento do ',
      'pagto de ',
      'pagto da ',
      'pag de ',
      'pag da ',
      'referente a ',
      'referente ao ',
      'referente à ',
      'ref. ',
      'ref ',
    ];

    for (final prefixo in prefixosParaRemover) {
      if (normalizado.startsWith(prefixo)) {
        normalizado = normalizado.substring(prefixo.length);
        break;
      }
    }

    // Colapsa espaços duplicados que possam ter sobrado.
    normalizado = normalizado.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalizado;
  }

  String _removerAcentos(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

    var resultado = texto;
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  Widget _buildListaDeDespesas(RelatorioFinanceiroSafra relatorio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Despesas da Safra',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppCores.verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        ...relatorio.transacoes.map(_buildDespesaCard),
      ],
    );
  }

  Widget _buildDespesaCard(TransacaoRelatorioSafra transacao) {
    final despesa = transacao.despesa;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    despesa.descricaoTexto,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  despesa.valorFormatado,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${despesa.formaPagamento.rotulo} · ${transacao.origemFormatada}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (despesa.dataHoraFormatada != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Data: ${despesa.dataHoraFormatada}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            if (despesa.beneficiado != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Beneficiado: ${despesa.beneficiadoTexto}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Acumulador auxiliar usado para somar valores de descrições equivalentes
/// e guardar o rótulo escolhido para exibição no gráfico.
class _GrupoDescricao {
  _GrupoDescricao({required this.rotulo});

  final String rotulo;
  num total = 0;
}