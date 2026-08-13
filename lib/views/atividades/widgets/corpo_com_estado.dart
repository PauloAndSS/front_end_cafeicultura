import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';

const _verdePrimario = Color(0xFF67835C);

/// Cascata de estados de uma tela que carrega dados: carregando → erro →
/// vazio → conteúdo.
///
/// A ordem é fixa e é justamente o ponto: com as guardas soltas em cada tela,
/// uma delas acabava testando "vazio" antes de "carregando" e piscava a
/// mensagem de lista vazia durante a requisição.
///
/// O vazio entra por builder porque a moldura muda entre as telas — na aba é
/// uma frase centralizada, no formulário é ícone + frase + "Tentar novamente".
class CorpoComEstado extends StatelessWidget {
  final bool isLoading;
  final String? mensagemErro;
  final bool vazio;
  final WidgetBuilder construirVazio;
  final WidgetBuilder construirConteudo;

  /// `null` esconde o botão de retentar na tela de erro.
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
        child: CircularProgressIndicator(color: _verdePrimario),
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
