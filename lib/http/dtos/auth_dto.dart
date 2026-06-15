class LoginRequestDTO {
  final String tipoEntrada;
  final String entrada;
  final String senha;

  LoginRequestDTO({
    required this.tipoEntrada,
    required this.entrada,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      "tipoEntrada": tipoEntrada,
      "entrada": entrada,
      "senha": senha,
    };
  }
}

class LoginResponseDTO {
  final String mensagem;
  final Map<String, dynamic>? sessaoAtiva; 

  LoginResponseDTO.fromJson(Map<String, dynamic> json)
      : mensagem = json['mensagem'],
        sessaoAtiva = json['sessaoAtiva'];
}