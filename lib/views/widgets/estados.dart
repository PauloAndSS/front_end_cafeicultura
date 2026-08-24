import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class MensagemDeErro extends StatelessWidget {
  final String mensagem;

  final VoidCallback? aoTentarNovamente;

  final EdgeInsetsGeometry padding;

  const MensagemDeErro({
    super.key,
    required this.mensagem,
    this.aoTentarNovamente,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          if (aoTentarNovamente != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: aoTentarNovamente,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: AppCores.verdePrimario),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EstadoVazio extends StatelessWidget {
  final String mensagem;
  final IconData? icone;
  final Widget? acao;

  const EstadoVazio({
    super.key,
    required this.mensagem,
    this.icone,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 48, color: Colors.black26),
              const SizedBox(height: 16),
            ],
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            if (acao != null) ...[const SizedBox(height: 24), acao!],
          ],
        ),
      ),
    );
  }
}

class RodapePaginacao extends StatelessWidget {
  final bool carregando;
  final String? mensagemErro;
  final VoidCallback? aoTentarNovamente;
  final EdgeInsetsGeometry padding;

  const RodapePaginacao({
    super.key,
    required this.carregando,
    this.mensagemErro,
    this.aoTentarNovamente,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return Padding(
        padding: padding,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppCores.verdePrimario,
            ),
          ),
        ),
      );
    }

    final erro = mensagemErro;

    if (erro == null) return const SizedBox.shrink();

    return MensagemDeErro(
      mensagem: erro,
      aoTentarNovamente: aoTentarNovamente,
      padding: padding,
    );
  }
}

class CartaoDeErro extends StatelessWidget {
  final String mensagem;

  const CartaoDeErro({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            mensagem,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class CartaoVazio extends StatelessWidget {
  final IconData icone;
  final String mensagem;

  const CartaoVazio({
    super.key,
    required this.icone,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(icone, size: 44, color: AppCores.verdeSecundario),
              const SizedBox(height: 12),
              Text(mensagem, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
