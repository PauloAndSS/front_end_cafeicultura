import 'dart:convert';

class MascaraDeLog {
  static const _trechosSensiveis = {
    'senha',
    'cpf',
    'cnpj',
    'email',
    'telefone',
    'ctps',
    'salario',
    'valorHora',
  };

  static const _chavesSensiveis = {'entrada'};

  static const _chavesDoCampoValidado = {'path', 'param'};

  static String aplicar(String corpo) {
    final Object? json;

    try {
      json = jsonDecode(corpo);
    } on FormatException {
      return corpo;
    }

    return jsonEncode(_mascarar(json));
  }

  static bool ehSensivel(String chave) {
    final normalizada = chave.toLowerCase();

    return _chavesSensiveis.contains(normalizada) ||
        _trechosSensiveis.any(normalizada.contains);
  }

  static Object? _mascarar(Object? valor) => switch (valor) {
        Map<String, dynamic> mapa => _mascararMapa(mapa),
        List<dynamic> lista => lista.map(_mascarar).toList(),
        _ => valor,
      };

  static Map<String, dynamic> _mascararMapa(Map<String, dynamic> mapa) {
    final validaCampoSensivel = _validaCampoSensivel(mapa);

    return mapa.map((chave, valor) {
      final oculto =
          ehSensivel(chave) || (chave == 'value' && validaCampoSensivel);

      if (!oculto) return MapEntry(chave, _mascarar(valor));

      return MapEntry(
        chave,
        _ehSenha(chave) ? _ocultarTudo(valor) : _ocultar(valor),
      );
    });
  }

  static bool _ehSenha(String chave) => chave.toLowerCase().contains('senha');

  static Object? _ocultarTudo(Object? valor) => valor == null ? null : '<oculto>';

  static bool _validaCampoSensivel(Map<String, dynamic> mapa) =>
      _chavesDoCampoValidado.any((chave) {
        final campo = mapa[chave];

        return campo is String && ehSensivel(campo);
      });

  static Object? _ocultar(Object? valor) => switch (valor) {
        null => null,
        String texto => '<oculto: ${texto.length} caracteres>',
        num _ => '<oculto: número>',
        _ => '<oculto>',
      };
}
