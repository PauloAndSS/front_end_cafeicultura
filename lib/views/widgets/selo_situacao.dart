import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class SeloDeSituacao extends StatelessWidget {
  final bool encerrado;
  final String rotuloAtivo;
  final String rotuloEncerrado;

  const SeloDeSituacao({
    super.key,
    required this.encerrado,
    required this.rotuloAtivo,
    required this.rotuloEncerrado,
  });

  const SeloDeSituacao.talhao({super.key, required this.encerrado})
      : rotuloAtivo = 'Ativo',
        rotuloEncerrado = 'Encerrado';

  const SeloDeSituacao.safra({super.key, required this.encerrado})
      : rotuloAtivo = 'Ativa',
        rotuloEncerrado = 'Encerrada';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: encerrado
            ? AppCores.fundoCampoInativo
            : AppCores.acao.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        encerrado ? rotuloEncerrado : rotuloAtivo,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: encerrado ? AppCores.textoSecundario : AppCores.acao,
        ),
      ),
    );
  }
}
