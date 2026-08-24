import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/widgets/propriedade_card.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class ResumoPropriedade extends StatefulWidget {
  final Propriedade propriedade;

  const ResumoPropriedade({super.key, required this.propriedade});

  @override
  State<ResumoPropriedade> createState() => _ResumoPropriedadeState();
}

class _ResumoPropriedadeState extends State<ResumoPropriedade> {
  bool _expandido = false;

  void _alternar() => setState(() => _expandido = !_expandido);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      sizeCurve: Curves.easeInOut,
      crossFadeState:
          _expandido ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: _construirBarraCompacta(),
      secondChild: CardPropriedadeWidget(
        propriedade: widget.propriedade,
        onTap: _alternar,
        iconeAcao: Icons.expand_less,
      ),
    );
  }

  Widget _construirBarraCompacta() {
    final propriedade = widget.propriedade;
    final endereco = propriedade.endereco;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _alternar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.landscape, color: AppCores.verdeSecundario, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propriedade.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${endereco.cidade} - ${endereco.uf.name} · '
                        '${propriedade.tamanho.formatado}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
