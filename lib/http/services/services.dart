abstract class BaseService {
  final String baseUrl = 'http://10.0.2.2:3333/api/v1'; //coordenadas para rodar no android studio
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
}