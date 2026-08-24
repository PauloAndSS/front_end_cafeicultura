import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/aparencia_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<void> mostrarAtividadesDoDia<T extends EventoAgricola>({
  required BuildContext context,
  required DateTime dia,
  required List<T> atividades,
  required String Function(int idTalhao) nomeDoTalhao,
  required void Function(T atividade) aoTocar,
  required String rotuloCadastrar,
  required VoidCallback aoCadastrar,
}) {
  return mostrarPainelModal<void>(
    context: context,
    construir: (context) => _PainelAtividadesDoDia<T>(
      dia: dia,
      atividades: atividades,
      nomeDoTalhao: nomeDoTalhao,
      aoTocar: aoTocar,
      rotuloCadastrar: rotuloCadastrar,
      aoCadastrar: aoCadastrar,
    ),
  );
}

class _PainelAtividadesDoDia<T extends EventoAgricola> extends StatelessWidget {
  final DateTime dia;
  final List<T> atividades;
  final String Function(int idTalhao) nomeDoTalhao;
  final void Function(T atividade) aoTocar;
  final String rotuloCadastrar;
  final VoidCallback aoCadastrar;

  const _PainelAtividadesDoDia({
    required this.dia,
    required this.atividades,
    required this.nomeDoTalhao,
    required this.aoTocar,
    required this.rotuloCadastrar,
    required this.aoCadastrar,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AlcaDoPainel(),
          _construirCabecalho(),
          if (atividades.isEmpty)
            const _DiaSemAtividades()
          else
            Flexible(child: _construirLista(context)),
          _construirBotaoCadastrar(context),
        ],
      ),
    );
  }

  Widget _construirCabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          const Icon(Icons.event, color: AppCores.verdeSecundario, size: 24),
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
          if (atividades.isNotEmpty)
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

  Widget _construirBotaoCadastrar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: CustomButton(
        text: rotuloCadastrar,
        onPressed: () {
          Navigator.pop(context);
          aoCadastrar();
        },
      ),
    );
  }

  Widget _construirLista(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      itemCount: atividades.length,
      itemBuilder: (context, indice) {
        final atividade = atividades[indice];

        return AtividadeCard(
          atividade: atividade,
          nomeTalhao: nomeDoTalhao(atividade.idTalhao),
          icone: iconeDaAtividade(atividade),
          onTap: () {
            Navigator.pop(context);
            aoTocar(atividade);
          },
        );
      },
    );
  }
}

class _DiaSemAtividades extends StatelessWidget {
  const _DiaSemAtividades();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: AppCores.verdeSecundario),
          SizedBox(height: 12),
          Text(
            'Nenhuma atividade neste dia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
