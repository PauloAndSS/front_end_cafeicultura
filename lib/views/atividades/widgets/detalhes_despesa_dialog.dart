import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/financeiro/despesa.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/blocos_detalhe.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

Future<bool> mostrarDetalhesDespesa({
  required BuildContext context,
  required Despesa despesa,
  bool podeExcluir = true,
  String? motivoBloqueio,
}) async {
  final excluir = await showDialog<bool>(
    context: context,
    builder: (_) => _DetalhesDespesaDialog(
      despesa: despesa,
      podeExcluir: podeExcluir,
      motivoBloqueio: motivoBloqueio,
    ),
  );

  return excluir ?? false;
}

class _DetalhesDespesaDialog extends StatelessWidget {
  final Despesa despesa;
  final bool podeExcluir;
  final String? motivoBloqueio;

  const _DetalhesDespesaDialog({
    required this.despesa,
    required this.podeExcluir,
    this.motivoBloqueio,
  });

  @override
  Widget build(BuildContext context) {
    final aviso = podeExcluir ? null : motivoBloqueio;
    final dataHoraFormatada = despesa.dataHoraFormatada;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Despesa',
        style: TextStyle(
          color: AppCores.verdePrimario,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinhaInfo(rotulo: 'Valor:', valor: despesa.valorFormatado),
            LinhaInfo(
              rotulo: 'Forma de pagamento:',
              valor: despesa.formaPagamento.rotulo,
            ),
            if (TransacaoFinanceira.operacaoUnica == null)
              LinhaInfo(
                rotulo: 'Tipo de operação:',
                valor: despesa.tipoOperacao.rotulo,
              ),
            LinhaInfo(
              rotulo: 'Beneficiado:',
              valor: despesa.beneficiadoTexto,
            ),
            LinhaInfo(rotulo: 'Descrição:', valor: despesa.descricaoTexto),
            if (dataHoraFormatada != null)
              LinhaInfo(rotulo: 'Lançada em:', valor: dataHoraFormatada),
            if (aviso != null) ...[
              const SizedBox(height: 16),
              CaixaAvisoAtencao(mensagem: aviso),
            ],
          ],
        ),
      ),
      actions: podeExcluir
          ? acoesDeDialogo(
              context: context,
              rotuloCancelar: 'Fechar',
              rotuloConfirmar: 'Excluir',
              corConfirmar: AppCores.erro,
              aoConfirmar: () => Navigator.of(context).pop(true),
            )
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
    );
  }
}
