class ApiValidationException implements Exception {
  final List<String> mensagens;

  ApiValidationException(this.mensagens);
}

class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);
}