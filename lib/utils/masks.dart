import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppMasks {
  static final cpf = MaskTextInputFormatter(
    mask: '###.###.###-##', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  static final cnpj = MaskTextInputFormatter(
    mask: '##.###.###/####-##', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  static final telefone = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  static final cep = MaskTextInputFormatter(
    mask: '#####-###', 
    filter: { "#": RegExp(r'[0-9]') },
  );
  
  static final inteiroMilhar = ThousandsSeparatorInputFormatter();
}

//máscara para números inteiros
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String apenasNumeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (apenasNumeros.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final numero = int.parse(apenasNumeros);
    final stringFormatada = _formatarComPontos(numero);

    return TextEditingValue(
      text: stringFormatada,
      selection: TextSelection.collapsed(offset: stringFormatada.length),
    );
  }

  String _formatarComPontos(int valor) {
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return valor.toString().replaceAllMapped(regExp, (Match match) => '${match[1]}.');
  }
}