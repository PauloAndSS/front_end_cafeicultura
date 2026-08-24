import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class FiltroStatusAtividade extends StatelessWidget {
  final StatusEvento? selecionado;
  final ValueChanged<StatusEvento?> onSelecionar;

  final List<StatusEvento?> filtros;

  const FiltroStatusAtividade({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
    this.filtros = StatusEvento.values,
  });

  bool get _apertado => filtros.length > 3;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatusEvento?>(
      showSelectedIcon: false,
      segments: filtros.map((status) {
        return ButtonSegment<StatusEvento?>(
          value: status,
          label: Text(
            rotuloDeFiltro(status, curto: _apertado),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
      selected: {selecionado},
      onSelectionChanged: (Set<StatusEvento?> novaSelecao) {
        onSelecionar(novaSelecao.first);
      },
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: _apertado ? 12 : 13),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: _apertado ? 4 : 8),
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
