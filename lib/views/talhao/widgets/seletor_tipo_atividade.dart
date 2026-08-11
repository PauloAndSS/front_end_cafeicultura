import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';

/// Select do tipo de atividade exibido na seção de atividades do talhão.
///
/// Usa `DropdownButton` dentro de um `Container` decorado em vez de
/// `DropdownButtonFormField`: o `value` deste último está deprecado e o
/// substituto `initialValue` guarda estado interno no `FormField` — reconstruir
/// com outro valor não mudaria o que aparece na tela. Aqui a seleção é
/// totalmente controlada por quem usa o widget.
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
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButton<TipoAtividade>(
        value: selecionado,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF67835C),
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
