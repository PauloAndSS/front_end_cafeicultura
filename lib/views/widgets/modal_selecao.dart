import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';

Future<T?> mostrarPainelModal<T>({
  required BuildContext context,
  required WidgetBuilder construir,
  bool alturaLivre = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: alturaLivre,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: construir,
  );
}

class AlcaDoPainel extends StatelessWidget {
  const AlcaDoPainel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppCores.borda,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class CabecalhoModal extends StatelessWidget {
  final String titulo;

  const CabecalhoModal({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Fechar sem alterar',
          ),
        ],
      ),
    );
  }
}

class CampoBuscaModal extends StatelessWidget {
  final TextEditingController controller;
  final String dica;

  const CampoBuscaModal({
    super.key,
    required this.controller,
    required this.dica,
  });

  @override
  Widget build(BuildContext context) {
    const borda = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppCores.borda),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: dica,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: borda,
          enabledBorder: borda,
        ),
      ),
    );
  }
}

class RodapeConfirmarModal extends StatelessWidget {
  final int quantidadeSelecionada;
  final VoidCallback aoConfirmar;

  const RodapeConfirmarModal({
    super.key,
    required this.quantidadeSelecionada,
    required this.aoConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppCores.borda)),
      ),
      child: CustomButton(
        text: 'Confirmar ($quantidadeSelecionada)',
        onPressed: aoConfirmar,
      ),
    );
  }
}
