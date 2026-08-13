import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/aparencia_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';

/// Painel com as atividades de um dia do calendário.
///
/// Mora no domínio de atividades, e não junto do calendário, porque monta
/// [AtividadeCard] — é o que mantém o calendário genérico e deixa este painel
/// reaproveitável pelas telas de atividade.
///
/// Não abre com a lista vazia: um dia sem marcador não tem o que mostrar, e um
/// painel vazio subindo a cada toque em espaço branco seria só ruído.
Future<void> mostrarAtividadesDoDia<T extends EventoAgricola>({
  required BuildContext context,
  required DateTime dia,
  required List<T> atividades,
  required String Function(int idTalhao) nomeDoTalhao,
  required void Function(T atividade) aoTocar,
}) {
  if (atividades.isEmpty) return Future.value();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _PainelAtividadesDoDia<T>(
      dia: dia,
      atividades: atividades,
      nomeDoTalhao: nomeDoTalhao,
      aoTocar: aoTocar,
    ),
  );
}

class _PainelAtividadesDoDia<T extends EventoAgricola> extends StatelessWidget {
  final DateTime dia;
  final List<T> atividades;
  final String Function(int idTalhao) nomeDoTalhao;
  final void Function(T atividade) aoTocar;

  const _PainelAtividadesDoDia({
    required this.dia,
    required this.atividades,
    required this.nomeDoTalhao,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    // Teto de 85% da tela: o painel cresce com o conteúdo, mas nunca cobre o
    // calendário por inteiro — o usuário precisa enxergar de que dia veio.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AlcaDoPainel(),
          _construirCabecalho(),
          Flexible(child: _construirLista(context)),
        ],
      ),
    );
  }

  Widget _construirCabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          const Icon(Icons.event, color: Color(0xFF8FA67E), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatarDataExtensa(dia),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            atividades.length == 1
                ? '1 atividade'
                : '${atividades.length} atividades',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _construirLista(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: atividades.length,
      itemBuilder: (context, indice) {
        final atividade = atividades[indice];

        return AtividadeCard(
          atividade: atividade,
          nomeTalhao: nomeDoTalhao(atividade.idTalhao),
          icone: iconeDaAtividade(atividade),
          onTap: () {
            // Fecha antes de entregar o controle: quem recebe normalmente
            // navega, e o painel ficaria empilhado atrás da tela de detalhes.
            Navigator.pop(context);
            aoTocar(atividade);
          },
        );
      },
    );
  }
}

class _AlcaDoPainel extends StatelessWidget {
  const _AlcaDoPainel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
