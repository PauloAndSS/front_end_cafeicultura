import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/viaCEP/endereco_ViaCEP.dart';
import 'package:http/http.dart' as http;

class ServiceViaCep extends ServiceExterno {
  @override
  String get baseUrl => 'https://viacep.com.br';

  @override
  String get recurso => 'ws';

  Future<EnderecoViaCep?> buscarCEP({required String cep}) {
    final digitos = _somenteDigitos(cep);

    return executarRequisicao(
      enviar: () => http.get(rota('$digitos/json/'), headers: defaultHeaders),
      aoSucesso: (resposta) {
        final json = extrairDadosResposta(resposta.bodyBytes);

        if (json is! Map<String, dynamic> || _cepInexistente(json)) return null;

        return EnderecoViaCep.fromJson(json);
      },
      errosPorStatus: {400: 'CEP inválido.'},
      erroMsg: 'Erro ao consultar o CEP.',
      acao: 'consultar o CEP',
    );
  }

  bool _cepInexistente(Map<String, dynamic> json) => json['erro'].toString() == 'true';

  String _somenteDigitos(String cep) => cep.replaceAll(RegExp(r'[^0-9]'), '');
}
