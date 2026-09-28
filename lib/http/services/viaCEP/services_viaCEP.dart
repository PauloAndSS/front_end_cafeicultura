class ServiceVIACEP extends BaseService {
  Future<EnderecoViaCep?> buscarCEP({required String cep}) async {
    final String cepFormatado = formatarCEP(cep);
    if (cepFormatado.length != 8) {
      throw Exception('Formato de CEP inválido');
    }

    return executarRequisicao(
      enviar: () => http.get(
        url: "https://viacep.com.br/ws/$cepFormatado/json/",
        headers: defaultHeaders,
      ),
      aoSucesso: (resposta) {
        if (resposta.data != null && resposta.data['erro'] == true) {
          return null; 
        }
          return EnderecoViaCep.fromJson(resposta.data);
      },
      erroMsg: 'Erro ao buscar CEP pelo viaCEP',
      acao: 'buscar CEP pelo viaCEP',
    );
  }
  String formatarCEP(String cep) {
    return cep.replaceAll(RegExp(r'[^0-9]'), '');
  }
}