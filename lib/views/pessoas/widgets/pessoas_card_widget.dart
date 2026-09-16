import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

class PessoaCardWidget extends StatelessWidget {
  final String nome;
  final String iniciais;
  final String subtitulo;
  final VoidCallback onTap;

  const PessoaCardWidget({
    super.key,
    required this.nome,
    required this.iniciais,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppEstilos.cartao(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _Monograma(iniciais: iniciais),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppCores.textoPrimario,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppCores.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppCores.textoTerciario,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Monograma extends StatelessWidget {
  final String iniciais;

  const _Monograma({required this.iniciais});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppCores.acao.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Text(
        iniciais,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppCores.acaoForte,
        ),
      ),
    );
  }
}
