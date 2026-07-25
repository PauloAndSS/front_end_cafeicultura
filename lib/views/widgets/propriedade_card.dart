// lib/views/widgets/card_propriedade_widget.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';

class CardPropriedadeWidget extends StatelessWidget {
  final Propriedade propriedade;
  final VoidCallback? onTap;

  const CardPropriedadeWidget({
    super.key,
    required this.propriedade,
    this.onTap, // Opcional: se não passar, ele não exibe setinha nem o efeito de clique
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.landscape, color: Color(0xFF8FA67E), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        propriedade.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (onTap != null)
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
                  value: '${propriedade.tamanho.valor} ${propriedade.tamanho.medida.name}',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Localização',
                  value: '${propriedade.endereco.cidade} - ${propriedade.endereco.uf.name}',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.map_outlined,
                  title: 'Endereço',
                  value: '${propriedade.endereco.logradouro}, ${propriedade.endereco.bairro}\nCEP: ${propriedade.endereco.cep.formatado}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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