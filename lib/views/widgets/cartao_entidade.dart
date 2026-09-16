import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';

class CartaoEntidade extends StatelessWidget {
  final IconData icone;
  final String titulo;

  final Widget? acao;

  final List<Widget> corpo;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry margem;

  const CartaoEntidade({
    super.key,
    required this.icone,
    required this.titulo,
    required this.corpo,
    this.acao,
    this.onTap,
    this.margem = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margem,
      decoration: AppEstilos.cartao(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icone, color: AppCores.acao, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppCores.textoPrimario,
                        ),
                      ),
                    ),
                    ?acao,
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: AppCores.borda, height: 1),
                ),
                ...corpo,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinhaCartao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const LinhaCartao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: AppCores.textoSecundario, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppCores.textoSecundario,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontSize: 15, color: AppCores.textoPrimario),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BadgeTexto extends StatelessWidget {
  final String texto;
  final Color cor;
  final EdgeInsetsGeometry margem;

  const BadgeTexto({
    super.key,
    required this.texto,
    required this.cor,
    this.margem = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margem,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
