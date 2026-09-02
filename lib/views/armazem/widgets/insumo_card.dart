import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/insumos/insumo.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback? onTap;
  final VoidCallback? aoRegistrarCompra;

  const InsumoCard({
    super.key,
    required this.insumo,
    this.onTap,
    this.aoRegistrarCompra,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: Icons.inventory_2_outlined,
      titulo: insumo.descricao,
      onTap: onTap,
      corpo: [
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.warehouse_outlined,
          titulo: 'Saldo em estoque',
          valor: insumo.saldoFormatado,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: aoRegistrarCompra,
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Registrar compra'),
            style: TextButton.styleFrom(
              foregroundColor: AppCores.verdeSecundario,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
