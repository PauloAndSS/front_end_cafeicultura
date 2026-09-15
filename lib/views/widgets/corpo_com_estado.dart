import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

class CorpoComEstado extends StatelessWidget {
  final bool isLoading;
  final String? mensagemErro;
  final bool vazio;
  final WidgetBuilder construirVazio;
  final WidgetBuilder construirConteudo;

  final bool manterConteudoAoRecarregar;

  final VoidCallback? aoTentarNovamente;

  const CorpoComEstado({
    super.key,
    required this.isLoading,
    required this.mensagemErro,
    required this.vazio,
    required this.construirVazio,
    required this.construirConteudo,
    this.aoTentarNovamente,
    this.manterConteudoAoRecarregar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && !(manterConteudoAoRecarregar && !vazio)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mensagemErro != null) {
      return _construirErro(mensagemErro!);
    }

    if (vazio) {
      return CorpoCentralizadoRolavel(filho: construirVazio(context));
    }

    return construirConteudo(context);
  }

  Widget _construirErro(String mensagem) {
    return CorpoCentralizadoRolavel(
      filho: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mensagem,
              style: const TextStyle(color: AppCores.erro),
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
