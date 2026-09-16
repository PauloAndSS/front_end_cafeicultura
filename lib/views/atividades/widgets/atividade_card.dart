import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/blocos_detalhes_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class AtividadeCard extends StatelessWidget {
  final EventoAgricola atividade;

  final String nomeTalhao;

  final IconData icone;

  final VoidCallback? onTap;

  const AtividadeCard({
    super.key,
    required this.atividade,
    required this.nomeTalhao,
    required this.icone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: icone,
      titulo: atividade.tituloExibicao,
      onTap: onTap,
      acao: BadgeStatusAtividade(atividade: atividade),
      corpo: [
        _construirDatas(),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.agriculture,
          titulo: 'Talhão',
          valor: nomeTalhao,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.notes,
          titulo: 'Descrição',
          valor: atividade.descricaoTexto,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.payments_outlined,
          titulo: 'Valor Gasto',
          valor: atividade.transacoesFinanceiras.totalFormatado,
        ),
      ],
    );
  }

  Widget _construirDatas() {
    final dataFimFormatada = atividade.dataFimFormatada;

    if (dataFimFormatada == null) return _dataInicio();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _dataInicio()),
        Expanded(
          child: LinhaCartao(
            icone: Icons.event_available,
            titulo: 'Data de Término',
            valor: dataFimFormatada,
          ),
        ),
      ],
    );
  }

  Widget _dataInicio() {
    return LinhaCartao(
      icone: Icons.calendar_today,
      titulo: 'Data de Início',
      valor: atividade.dataInicioFormatada,
    );
  }
}
