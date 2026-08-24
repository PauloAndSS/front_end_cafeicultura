import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CorpoComEstado extends StatelessWidget {
  final bool isLoading;
  final String? mensagemErro;
  final bool vazio;
  final WidgetBuilder construirVazio;
  final WidgetBuilder construirConteudo;

  final VoidCallback? aoTentarNovamente;

  const CorpoComEstado({
    super.key,
    required this.isLoading,
    required this.mensagemErro,
    required this.vazio,
    required this.construirVazio,
    required this.construirConteudo,
    this.aoTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.verdePrimario),
      );
    }

    if (mensagemErro != null) {
      return _construirErro(mensagemErro!);
    }

    if (vazio) return construirVazio(context);

    return construirConteudo(context);
  }

  Widget _construirErro(String mensagem) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mensagem,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            if (aoTentarNovamente != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Tentar novamente',
                  onPressed: aoTentarNovamente,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
