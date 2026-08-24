class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  bool get indicaAusenciaDeRegistros {
    final normalizada = _semAcentos(mensagem.toLowerCase());

    final indicaAusencia = normalizada.contains('nao possui') ||
        normalizada.contains('nenhum') ||
        normalizada.contains('sem eventos') ||
        normalizada.contains('sem registro');

    final indicaRegistros = normalizada.contains('evento') ||
        normalizada.contains('registrad') ||
        normalizada.contains('exemplo') ||
        normalizada.contains('relatorio');

    return indicaAusencia && indicaRegistros;
  }

  @override
  String toString() => mensagem;
}

class ApiValidationException extends ApiException {
  final List<String> mensagens;

  ApiValidationException(this.mensagens) : super(mensagens.join('\n'));
}

String _semAcentos(String texto) {
  const comAcento = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  var resultado = texto;
  for (var i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }
  return resultado;
}
