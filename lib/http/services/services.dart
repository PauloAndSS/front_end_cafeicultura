import 'package:http/http.dart' as http;

abstract class BaseService {
  final String baseUrl = 'http://10.0.2.2:3333/api/v1';
  static String? sessionCookie;

  Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (sessionCookie != null) {
      headers['Cookie'] = sessionCookie!;
    }

    return headers;
  }

  static void atualizarCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      print('✅ COOKIE SALVO COM SUCESSO: $sessionCookie');
    } else {
      print('❌ O BACK-END NÃO ENVIOU COOKIE NO CADASTRO');
    }
  }
}