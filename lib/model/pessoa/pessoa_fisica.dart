import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';

class CPF {
  final String numero;

  CPF._(this.numero);

  factory CPF.criar(String valor) {
    if (!isValid(valor)) {
      throw ArgumentError('CPF inválido');
    }
    final numerosLimpos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    return CPF._(numerosLimpos);
  }

static bool isValid(String valor) {

    final cpfLimpo = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpfLimpo.length != 11) return false;
    if (_todosOsNumerosSaoIguais(cpfLimpo)) return false;

    final baseCpf = cpfLimpo.substring(0, 9);
    final primeiroDigitoRecebido = int.parse(cpfLimpo[9]);
    final segundoDigitoRecebido = int.parse(cpfLimpo[10]);

    final primeiroDigitoCalculado = _calcularDigitoVerificador(
      baseCpf, 
      pesoInicial: 10,
    );
    
    if (primeiroDigitoCalculado != primeiroDigitoRecebido) return false;

    final baseCpfComPrimeiroDigito = baseCpf + primeiroDigitoCalculado.toString();
    final segundoDigitoCalculado = _calcularDigitoVerificador(
      baseCpfComPrimeiroDigito, 
      pesoInicial: 11,
    );

    return segundoDigitoCalculado == segundoDigitoRecebido;
  }
static bool _todosOsNumerosSaoIguais(String cpf) {
    return RegExp(r'^(\d)\1*$').hasMatch(cpf);
  }

  /// Realiza a matemática da Receita Federal para descobrir o dígito verificador.
  /// Reutilizado para o 1º e 2º dígitos apenas mudando o [pesoInicial].
  static int _calcularDigitoVerificador(String baseCpf, {required int pesoInicial}) {
    int somaMultiplicacoes = 0;
    int pesoAtual = pesoInicial;

    for (int i = 0; i < baseCpf.length; i++) {
      final digitoAtual = int.parse(baseCpf[i]);
      somaMultiplicacoes += (digitoAtual * pesoAtual);
      pesoAtual--;
    }

    final resto = (somaMultiplicacoes * 10) % 11;
    
    return resto == 10 ? 0 : resto;
  }

  String get formatado {
    return '${numero.substring(0, 3)}.${numero.substring(3, 6)}.${numero.substring(6, 9)}-${numero.substring(9, 11)}';
  }
}

class PessoaFisica extends Pessoa {
  final String nome;
  final CPF cpf;

  PessoaFisica({
    super.id,
    required this.nome,
    required this.cpf,
    super.endereco
  });
}