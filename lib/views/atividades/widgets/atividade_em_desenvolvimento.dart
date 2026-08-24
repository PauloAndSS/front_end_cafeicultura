import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/em_desenvolvimento_widget.dart';

class AtividadeEmDesenvolvimento extends StatelessWidget {
  final TipoAtividade tipo;

  const AtividadeEmDesenvolvimento({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return EmDesenvolvimentoWidget(titulo: 'Tela de ${tipo.rotulo}');
  }
}
