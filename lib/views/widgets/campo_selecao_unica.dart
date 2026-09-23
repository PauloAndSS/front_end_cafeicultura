import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class CampoSelecaoUnica<T> extends FormField<T> {
  final IconData icone;
  final String dica;
  final String Function(T valor) rotuloDoValor;
  final Future<T?> Function() aoAbrir;
  final ValueChanged<T> aoSelecionar;
  final bool habilitado;

  CampoSelecaoUnica({
    super.key,
    required T? valor,
    required this.icone,
    required this.dica,
    required this.rotuloDoValor,
    required this.aoAbrir,
    required this.aoSelecionar,
    super.validator,
    this.habilitado = true,
  }) : super(
          initialValue: valor,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (estado) => _CorpoDoCampo<T>(
            estado: estado,
            icone: icone,
            dica: dica,
            rotuloDoValor: rotuloDoValor,
            aoTocar: habilitado ? () => _abrir(estado, aoAbrir, aoSelecionar) : null,
          ),
        );

  static Future<void> _abrir<T>(
    FormFieldState<T> estado,
    Future<T?> Function() aoAbrir,
    ValueChanged<T> aoSelecionar,
  ) async {
    final escolhido = await aoAbrir();

    if (escolhido == null) return;

    estado.didChange(escolhido);
    aoSelecionar(escolhido);
  }

  @override
  FormFieldState<T> createState() => _CampoSelecaoUnicaState<T>();
}

class _CampoSelecaoUnicaState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

class _CorpoDoCampo<T> extends StatelessWidget {
  final FormFieldState<T> estado;
  final IconData icone;
  final String dica;
  final String Function(T valor) rotuloDoValor;
  final VoidCallback? aoTocar;

  const _CorpoDoCampo({
    required this.estado,
    required this.icone,
    required this.dica,
    required this.rotuloDoValor,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final selecionado = estado.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: estado.hasError ? AppCores.erro : AppCores.bordaCampo,
              ),
            ),
            child: Row(
              children: [
                Icon(icone, color: AppCores.acao),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selecionado == null ? dica : rotuloDoValor(selecionado),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: selecionado == null
                          ? AppCores.textoTerciario
                          : AppCores.textoPrimario,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppCores.textoTerciario),
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
}
