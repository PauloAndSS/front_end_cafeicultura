import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/em_desenvolvimento_widget.dart';

/// Placeholder das atividades que ainda não têm tela.
///
/// Quem decide se um tipo cai aqui é o registro em `registro_atividades.dart`,
/// não um flag no enum.
class AtividadeEmDesenvolvimento extends StatelessWidget {
  final TipoAtividade tipo;

  const AtividadeEmDesenvolvimento({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return EmDesenvolvimentoWidget(titulo: 'Tela de ${tipo.rotulo}');
  }
}
