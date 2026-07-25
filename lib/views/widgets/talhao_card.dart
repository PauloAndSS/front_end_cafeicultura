import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/detalhes_talhao_view.dart';

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
    final dataFormatada = 
        '${talhao.dataInicio.day.toString().padLeft(2, '0')}/${talhao.dataInicio.month.toString().padLeft(2, '0')}/${talhao.dataInicio.year}';

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
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesTalhaoView(talhao: talhao),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.agriculture, color: Color(0xFF8FA67E), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        talhao.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Color(0xFFE0E0E0), height: 1),
                ),
                _buildInfoRow(
                  icon: Icons.square_foot,
                  title: 'Tamanho',
                  value: '${talhao.tamanho.valor} ${talhao.tamanho.medida.name}',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.eco_outlined,
                  title: 'Espécie',
                  value: talhao.especie.isNotEmpty 
                      ? talhao.especie[0].toUpperCase() + talhao.especie.substring(1) 
                      : 'Não informada', 
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.grass,
                        title: 'Pés de Café',
                        value: '${talhao.qtdPeCafe}',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today,
                        title: 'Data de Início',
                        value: dataFormatada,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // O mesmo construtor de linhas elegantes, agora interno ao widget
  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
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
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}