import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_despesa.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_safra.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/relatorio_financeiro_safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/financeiro/financeiro_mudou.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class FinanceiroViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final ServicesSafra _serviceSafra = ServicesSafra();
  final ServicesDespesa _serviceDespesa = ServicesDespesa();

  /// Usado para avisar outras telas (ex: a aba Safra) que os dados
  /// financeiros mudaram, para que possam recarregar seus próprios
  /// relatórios. Opcional para não quebrar quem já instancia este
  /// ViewModel sem esse parâmetro.
  final FinanceiroMudou? _financeiroMudou;

  FinanceiroViewModel({FinanceiroMudou? financeiroMudou})
      : _financeiroMudou = financeiroMudou;

  RelatorioFinanceiroSafra _relatorio = RelatorioFinanceiroSafra.vazio;
  int? _idPropriedade;
  int? _idSafra;

  RelatorioFinanceiroSafra get relatorio => _relatorio;
  List<Despesa> get despesas =>
      _relatorio.transacoes.map((t) => t.despesa).toList();

  num get custoTotal => _relatorio.custoTotal;

  Future<void> carregarRelatorio({
    required int idPropriedade,
    required int idSafra,
    bool emSegundoPlano = false,
  }) async {
    _idPropriedade = idPropriedade;
    _idSafra = idSafra;

    final carga = emSegundoPlano ? null : cargaPrincipal;

    await (carga?.executar(
          chamada: () async {
            _relatorio = await _serviceSafra.buscarRelatorioFinanceiro(
              idPropriedade: idPropriedade,
              idSafra: idSafra,
            );
          },
          aoFalhar: () {},
        ) ??
        _buscarSemBloqueio());

    notificarSeVivo();
  }

Future<void> _buscarSemBloqueio() async {
    try {
      _relatorio = await _serviceSafra.buscarRelatorioFinanceiro(
        idPropriedade: _idPropriedade!,
        idSafra: _idSafra!,
      );
    } catch (error) {
      debugPrint('[Financeiro] falha no refresh silencioso: $error');
    }
  }

  Future<bool> cadastrarDespesa(Despesa despesa) async {
    final bool sucesso = await cargaPrincipal.executar(
          chamada: () async {
            final nova = await _serviceDespesa.cadastrar(despesa);
            return nova != null;
          },
          aoFalhar: () {},
        ) ??
        false;

    if (sucesso) {
      await carregarRelatorio(
        idPropriedade: _idPropriedade!,
        idSafra: _idSafra!,
        emSegundoPlano: true,
      );
      _financeiroMudou?.invalidar();
    }

    return sucesso;
  }

  Future<bool> excluirDespesa(int idDespesa) async {
    final bool sucesso = await cargaPrincipal.executar(
          chamada: () => _serviceDespesa.excluir(idDespesa),
          aoFalhar: () {},
        ) ??
        false;

    if (sucesso) {
      await carregarRelatorio(
        idPropriedade: _idPropriedade!,
        idSafra: _idSafra!,
        emSegundoPlano: true,
      );
      _financeiroMudou?.invalidar();
    }

    return sucesso;
  }
}