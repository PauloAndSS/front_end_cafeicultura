class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiValidationException extends ApiException {
  final List<String> mensagens;

  ApiValidationException(this.mensagens) : super(mensagens.join('\n'));
}