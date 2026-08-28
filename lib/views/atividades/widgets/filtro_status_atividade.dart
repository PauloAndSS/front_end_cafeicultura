import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

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
          label: Text(status.filtro, textAlign: TextAlign.center),
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
        backgroundColor: WidgetStateProperty.resolveWith<Color>((estados) {
          if (estados.contains(WidgetState.selected)) {
            return AppCores.verdePrimario;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((estados) {
          if (estados.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
      ),
    );
  }
}
