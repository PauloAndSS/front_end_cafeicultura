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
    return {"tipoEntrada": tipoEntrada, "entrada": entrada, "senha": senha};
  }
}

class SessaoAtivaDTO {
  final int? idUsuario;
  final String? nome;
  final List<int> idsPropriedades;

  SessaoAtivaDTO.fromJson(Map<String, dynamic> json)
      : idUsuario = (json['id']) as int?,
        nome = (json['nome']) as String?,
        idsPropriedades = (json['idsPropriedades'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ?? []; 
}

class LoginResponseDTO {
  final String mensagem;
  final SessaoAtivaDTO? sessaoAtiva;

  LoginResponseDTO.fromJson(Map<String, dynamic> json)
    : mensagem = json['mensagem'] ?? '',
      sessaoAtiva = json['dadosSessao'] != null
          ? SessaoAtivaDTO.fromJson(json['dadosSessao'])
          : null;
}
