import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/notificacoes/notificacao_agrupada.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/aparencia_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class NotificacaoCard extends StatelessWidget {
  final NotificacaoAgrupada grupo;

  final TratoCultural? atividade;

  final DateTime dataDoEvento;

  final String nomeTalhao;

  final bool confirmada;

  final bool precisaResponder;

  final VoidCallback? aoAbrir;
  final VoidCallback? aoResponderSim;
  final VoidCallback? aoAlterar;
  final VoidCallback? aoExcluir;

  const NotificacaoCard({
    super.key,
    required this.grupo,
    required this.atividade,
    required this.dataDoEvento,
    required this.nomeTalhao,
    this.confirmada = false,
    this.precisaResponder = false,
    this.aoAbrir,
    this.aoResponderSim,
    this.aoAlterar,
    this.aoExcluir,
  });

  String get _titulo =>
      atividade?.tituloExibicao ?? grupo.representante.tituloGenerico;

  IconData get _icone {
    final trato = atividade;

    return trato == null
        ? Icons.notifications_active_outlined
        : iconeDaAtividade(trato);
  }

  String get _rotuloBadge {
    if (confirmada) return 'Confirmada';
    if (precisaResponder) return 'Ocorreu?';

    return rotuloDeHorizonte(dataDoEvento);
  }

  Color get _corBadge {
    if (confirmada) return AppCores.sucesso;
    if (precisaResponder) return AppCores.aviso;

    return AppCores.acao;
  }

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: _icone,
      titulo: _titulo,
      onTap: aoAbrir,
      acao: BadgeTexto(texto: _rotuloBadge, cor: _corBadge),
      corpo: [
        LinhaCartao(
          icone: Icons.schedule,
          titulo: 'Quando',
          valor: textoDeQuando(dataDoEvento),
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.agriculture,
          titulo: 'Talhão',
          valor: nomeTalhao,
        ),
        if (precisaResponder) ...[
          const SizedBox(height: 20),
          const Text(
            'Esse trato cultural ocorreu?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(text: 'Sim', onPressed: aoResponderSim),
          const SizedBox(height: 4),
          _AcaoSecundaria(
            texto: 'Ainda não. Alterar informações',
            cor: AppCores.acao,
            onPressed: aoAlterar,
          ),
          _AcaoSecundaria(
            texto: 'Não, excluir esse trato',
            cor: AppCores.erro,
            onPressed: aoExcluir,
          ),
        ],
      ],
    );
  }
}

class _AcaoSecundaria extends StatelessWidget {
  final String texto;
  final Color cor;
  final VoidCallback? onPressed;

  const _AcaoSecundaria({
    required this.texto,
    required this.cor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: cor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
