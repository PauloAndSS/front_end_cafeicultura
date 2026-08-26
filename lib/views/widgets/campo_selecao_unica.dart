import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CampoSelecaoUnica<T> extends StatelessWidget {
  final T? valor;
  final IconData icone;
  final String dica;
  final String Function(T valor) rotuloDoValor;
  final Future<T?> Function() aoAbrir;
  final ValueChanged<T> aoSelecionar;
  final FormFieldValidator<T>? validator;
  final bool habilitado;

  const CampoSelecaoUnica({
    super.key,
    required this.valor,
    required this.icone,
    required this.dica,
    required this.rotuloDoValor,
    required this.aoAbrir,
    required this.aoSelecionar,
    this.validator,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: valor,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: _construirCampo,
    );
  }

  Widget _construirCampo(FormFieldState<T> estado) {
    final selecionado = estado.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: habilitado ? () => _abrir(estado) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: estado.hasError ? AppCores.erro : AppCores.borda,
              ),
            ),
            child: Row(
              children: [
                Icon(icone, color: AppCores.verdePrimario),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selecionado == null ? dica : rotuloDoValor(selecionado),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          selecionado == null ? Colors.black26 : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
        if (estado.hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              estado.errorText!,
              style: const TextStyle(color: AppCores.erro, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _abrir(FormFieldState<T> estado) async {
    final escolhido = await aoAbrir();

    if (escolhido == null) return;

    estado.didChange(escolhido);
    aoSelecionar(escolhido);
  }
}
