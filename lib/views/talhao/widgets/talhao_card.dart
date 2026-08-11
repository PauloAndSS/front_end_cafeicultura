import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';

class TalhaoCard extends StatelessWidget {
  final Talhao talhao;
  final VoidCallback? onTap;

  const TalhaoCard({
    super.key,
    required this.talhao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool estaEncerrado =
        talhao.dataFim != null || talhao.arquivado == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.agriculture,
                      color: Color(0xFF8FA67E),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        talhao.nomeExibicao,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (estaEncerrado)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Encerrado',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black26,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Color(0xFFE0E0E0), height: 1),
                ),
                _buildInfoRow(
                  icon: Icons.square_foot,
                  title: 'Tamanho',
                  value: talhao.tamanhoFormatado,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.eco_outlined,
                  title: 'Espécie',
                  value: talhao.especieFormatada,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.category_outlined,
                  title: 'Variedades de Café',
                  value: talhao.variedadesTexto,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.grass,
                        title: 'Pés de Café',
                        value: talhao.qtdPeCafeFormatada,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today,
                        title: 'Data de Início',
                        value: talhao.dataInicioFormatada,
                      ),
                    ),
                  ],
                ),
                if (talhao.dataFimFormatada != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    title: 'Data de Encerramento',
                    value: talhao.dataFimFormatada!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}