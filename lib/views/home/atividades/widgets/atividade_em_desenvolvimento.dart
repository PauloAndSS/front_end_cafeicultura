import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';

/// Placeholder das atividades que ainda não têm tela.
///
/// Quem decide se um tipo cai aqui é o registro em `registro_atividades.dart`,
/// não um flag no enum.
class AtividadeEmDesenvolvimento extends StatelessWidget {
  final TipoAtividade tipo;

  const AtividadeEmDesenvolvimento({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: Color(0xFF8FA67E)),
          const SizedBox(height: 16),
          Text(
            'Tela de ${tipo.rotulo}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF67835C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Em desenvolvimento...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
