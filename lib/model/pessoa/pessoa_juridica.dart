import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

class CNPJ {
  final String numero;

  CNPJ._(this.numero);

  factory CNPJ.criar(String valor) {
    if (!isValid(valor)) {
      throw ArgumentError('CNPJ inválido');
    }
    final numerosLimpos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    return CNPJ._(numerosLimpos);
  }

  static bool isValid(String valor) {
    final cnpjLimpo = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpjLimpo.length != 14) return false;
    if (_todosOsNumerosSaoIguais(cnpjLimpo)) return false;

    final baseCnpj = cnpjLimpo.substring(0, 12);
    final primeiroDigitoRecebido = int.parse(cnpjLimpo[12]);
    final segundoDigitoRecebido = int.parse(cnpjLimpo[13]);

    final pesosPrimeiroDigito = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final primeiroDigitoCalculado = _calcularDigitoVerificador(
      baseCnpj, 
      pesosPrimeiroDigito,
    );
    
    if (primeiroDigitoCalculado != primeiroDigitoRecebido) return false;

    final baseCnpjComPrimeiroDigito = baseCnpj + primeiroDigitoCalculado.toString();
    final pesosSegundoDigito = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final segundoDigitoCalculado = _calcularDigitoVerificador(
      baseCnpjComPrimeiroDigito, 
      pesosSegundoDigito,
    );

    return segundoDigitoCalculado == segundoDigitoRecebido;
  }

  static bool _todosOsNumerosSaoIguais(String cnpj) {
    return RegExp(r'^(\d)\1*$').hasMatch(cnpj);
  }

  static int _calcularDigitoVerificador(String baseCnpj, List<int> pesos) {
    int somaMultiplicacoes = 0;

    for (int i = 0; i < baseCnpj.length; i++) {
      final digitoAtual = int.parse(baseCnpj[i]);
      somaMultiplicacoes += digitoAtual * pesos[i];
    }

    final resto = somaMultiplicacoes % 11;
    
    return resto < 2 ? 0 : 11 - resto;
  }

  String get formatado {
    return '${numero.substring(0, 2)}.${numero.substring(2, 5)}.${numero.substring(5, 8)}/${numero.substring(8, 12)}-${numero.substring(12, 14)}';
  }
}

class PessoaJuridica extends Pessoa {
  final CNPJ cnpj;
  final String razaoSocial;
  final String? inscricaoEstadual;

  PessoaJuridica({
    required super.id,
    required this.cnpj,
    required this.razaoSocial,
    this.inscricaoEstadual,
    super.endereco
  });
}