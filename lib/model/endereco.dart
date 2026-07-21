enum UF {
  AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, 
  PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO;
}

class CEP {
  final String numero;

  CEP._(this.numero);

  factory CEP.criar(String valor) {
    final numerosLimpos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numerosLimpos.length != 8) {
      throw ArgumentError('CEP deve conter exatamente 8 dígitos');
    }
    
    return CEP._(numerosLimpos);
  }

  String get formatado {
    return '${numero.substring(0, 5)}-${numero.substring(5)}';
  }

}

class Endereco {
  final int? id;
  final String cidade;
  final CEP cep;
  final UF uf;
  final String pais;
  final String bairro;
  final String logradouro;

  Endereco({
    this.id,
    required this.cidade,
    required this.cep,
    required this.uf,
    required this.bairro,
    required this.logradouro,
    this.pais = "Brasil",
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      id: json['id'],
      cidade: json['cidade'],
      bairro: json['bairro'],
      logradouro: json['logradouro'],
      cep: CEP.criar(json['cep']),
      uf: UF.values.firstWhere(
        (e) => e.name.toUpperCase() == json['uf'].toString().toUpperCase(),
        orElse: () => throw ArgumentError('UF inválida: ${json['uf']}'),
      ),
      pais: json['pais'] ?? 'Brasil', 
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cidade': cidade,
    'bairro': bairro,
    'logradouro': logradouro,
    'cep': cep.formatado,
    'uf': uf.name,
    'pais': pais,
  };
}