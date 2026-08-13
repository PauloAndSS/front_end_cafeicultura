import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';

/// Alternador entre atividades agendadas, em andamento e finalizadas.
///
/// Usado tanto nas abas de atividade quanto na seção de atividades do detalhe
/// do talhão — o estado da seleção fica com quem usa.
///
/// Filtra pelo mesmo [StatusEvento] que o model calcula: um enum próprio de
/// filtro seria a mesma regra escrita duas vezes.
///
/// Sem os ícones que existiam quando eram dois segmentos: com três rótulos,
/// ícone mais texto não cabe na largura de um telefone comum.
class FiltroStatusAtividade extends StatelessWidget {
  final StatusEvento selecionado;
  final ValueChanged<StatusEvento> onSelecionar;

  const FiltroStatusAtividade({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatusEvento>(
      showSelectedIcon: false,
      segments: StatusEvento.values.map((status) {
        return ButtonSegment<StatusEvento>(
          value: status,
          label: Text(status.rotuloFiltro, textAlign: TextAlign.center),
        );
      }).toList(),
      selected: {selecionado},
      onSelectionChanged: (Set<StatusEvento> novaSelecao) {
        onSelecionar(novaSelecao.first);
      },
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8),
        ),
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
