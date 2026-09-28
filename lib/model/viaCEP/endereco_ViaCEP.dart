class EnderecoViaCep {
  final String cep;
  final String localidade; 
  final String uf;        
  final String logradouro; 
  final String bairro;     
  final String complemento;

  EnderecoViaCep({
    required this.cep,
    required this.localidade,
    required this.uf,
    this.logradouro = '',
    this.bairro = '',
    this.complemento = '',
  });

  factory EnderecoViaCep.fromJson(Map<String, dynamic> json) {
    return EnderecoViaCep(
      cep: json['cep'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      complemento: json['complemento'] ?? '',
    );
  }
}