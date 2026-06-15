class ApiValidationException implements Exception {
  final List<String> mensagens;

  ApiValidationException(this.mensagens);

  @override
  String toString() => mensagens.join('\n');
}

class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}