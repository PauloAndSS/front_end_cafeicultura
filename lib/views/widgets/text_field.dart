import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool opcional;
  final bool habilitado;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
    this.opcional = false,
    this.habilitado = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _senhaOculta = true;

  void _alternarVisibilidadeDaSenha() {
    setState(() => _senhaOculta = !_senhaOculta);
  }

  Widget? _botaoDeVisibilidade() {
    if (!widget.isPassword) return null;
    return IconButton(
      onPressed: widget.habilitado ? _alternarVisibilidadeDaSenha : null,
      tooltip: _senhaOculta ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        _senhaOculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, widget.label, opcional: widget.opcional),
        TextFormField(
          controller: widget.controller,
          enabled: widget.habilitado,
          obscureText: widget.isPassword && _senhaOculta,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: widget.readOnly || !widget.habilitado,
            suffixIcon: _botaoDeVisibilidade(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
