import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class SeletorTipoAtividade extends StatelessWidget {
  final TipoAtividade selecionado;
  final ValueChanged<TipoAtividade> onSelecionar;

  const SeletorTipoAtividade({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppCores.borda),
      ),
      child: DropdownButton<TipoAtividade>(
        value: selecionado,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppCores.verdePrimario,
        ),
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        items: TipoAtividade.values.map((tipo) {
          return DropdownMenuItem<TipoAtividade>(
            value: tipo,
            child: Text(tipo.rotulo),
          );
        }).toList(),
        onChanged: (novoTipo) {
          if (novoTipo != null) onSelecionar(novoTipo);
        },
      ),
    );
  }
}
