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
  static final decimal = DecimalInputFormatter(casasDecimais: 2);

  /// Desfaz a máscara pt-BR (milhar com ponto, decimal com vírgula) e devolve
  /// o número. `null` se o texto não for numérico.
  static double? paraDouble(String texto) {
    return double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.'));
  }
}

//máscara para decimais
class DecimalInputFormatter extends TextInputFormatter {
  final int casasDecimais;

  DecimalInputFormatter({this.casasDecimais = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String textoNovo = newValue.text;

    if (textoNovo.endsWith('.')) {
      textoNovo = '${textoNovo.substring(0, textoNovo.length - 1)},';
    }

    if (','.allMatches(textoNovo).length > 1) {
      return oldValue;
    }

    final partes = textoNovo.split(',');

    String digitosInteiros = partes[0].replaceAll(RegExp(r'[^0-9]'), '');

    if (digitosInteiros.isEmpty && !textoNovo.startsWith(',')) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String parteInteiraFormatada = _formatarMilhar(digitosInteiros);

    String textoFinal = parteInteiraFormatada;

    if (textoNovo.contains(',')) {
      String parteDecimal = partes.length > 1 ? partes[1].replaceAll(RegExp(r'[^0-9]'), '') : '';

      if (parteDecimal.length > casasDecimais) {
        return oldValue;
      }

      textoFinal += ',$parteDecimal';
    }

    return TextEditingValue(
      text: textoFinal,
      selection: TextSelection.collapsed(offset: textoFinal.length),
    );
  }
  String _formatarMilhar(String digitos) {
    if (digitos.isEmpty) return '';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return digitos.replaceAllMapped(regExp, (Match match) => '${match[1]}.');
  }
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