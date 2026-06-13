abstract class BaseService {
  final String baseUrl = 'http://localhost:3333/api/v1';

  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}