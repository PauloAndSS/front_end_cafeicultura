import 'package:flutter/material.dart';

enum StatusAtividadeFiltro { emAndamento, finalizadas }

/// Alternador entre atividades em andamento e finalizadas.
///
/// Usado tanto nas abas de atividade quanto na seção de atividades do detalhe
/// do talhão — o estado da seleção fica com quem usa.
class FiltroStatusAtividade extends StatelessWidget {
  final StatusAtividadeFiltro selecionado;
  final ValueChanged<StatusAtividadeFiltro> onSelecionar;

  const FiltroStatusAtividade({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatusAtividadeFiltro>(
      segments: const [
        ButtonSegment<StatusAtividadeFiltro>(
          value: StatusAtividadeFiltro.emAndamento,
          label: Text('Em andamento'),
          icon: Icon(Icons.pending_actions),
        ),
        ButtonSegment<StatusAtividadeFiltro>(
          value: StatusAtividadeFiltro.finalizadas,
          label: Text('Finalizadas'),
          icon: Icon(Icons.task_alt),
        ),
      ],
      selected: {selecionado},
      onSelectionChanged: (Set<StatusAtividadeFiltro> novaSelecao) {
        onSelecionar(novaSelecao.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF67835C);
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
      ),
    );
  }
}
