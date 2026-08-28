class ResultadoPaginadoDTO<T> {
  final List<T> data;
  final int total;
  final int pagina;
  final int totalPaginas;

  ResultadoPaginadoDTO({
    required this.data,
    required this.total,
    required this.pagina,
    required this.totalPaginas,
  });

  factory ResultadoPaginadoDTO.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ResultadoPaginadoDTO(
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      total: json['total'] ?? 0,
      pagina: json['pagina'] ?? 1,
      totalPaginas: json['totalPaginas'] ?? 1,
    );
  }

  factory ResultadoPaginadoDTO.deEnvelopePaginado(
    Map<String, dynamic> json,
    String chaveDaLista,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final lista = json[chaveDaLista];

    return ResultadoPaginadoDTO(
      data: lista is List
          ? lista
              .whereType<Map<String, dynamic>>()
              .map((item) => fromJsonT(item))
              .toList()
          : <T>[],
      total: json['totalRegistros'] ?? json['total'] ?? 0,
      pagina: json['paginaAtual'] ?? 1,
      totalPaginas: json['totalPaginas'] ?? 1,
    );
  }

  /// Envelope `{ pagina, limite, dados }` das rotas por papel de pessoa.
  ///
  /// Ele nao traz `total` nem `totalPaginas`, entao o total de paginas e
  /// inferido: pagina cheia significa "pode haver mais". A pagina seguinte
  /// volta com `dados` vazio e encerra a rolagem, ao custo de uma requisicao.
  factory ResultadoPaginadoDTO.deEnvelopeDeDados(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT, {
    required int paginaSolicitada,
    required int limiteSolicitado,
  }) {
    final bruto = json['dados'] ?? json['data'];

    final itens = bruto is List
        ? bruto
            .whereType<Map<String, dynamic>>()
            .map((item) => fromJsonT(item))
            .toList()
        : <T>[];

    final pagina = _inteiroPositivo(json['pagina']) ?? paginaSolicitada;
    final limite = _inteiroPositivo(json['limite']) ?? limiteSolicitado;
    final total = _inteiroPositivo(json['total'] ?? json['totalRegistros']);

    return ResultadoPaginadoDTO(
      data: itens,
      total: total ?? itens.length,
      pagina: pagina,
      totalPaginas: _inteiroPositivo(json['totalPaginas']) ??
          (total != null && limite > 0
              ? (total / limite).ceil()
              : (itens.length < limite ? pagina : pagina + 1)),
    );
  }

  static int? _inteiroPositivo(dynamic valor) {
    final numero = valor is int ? valor : int.tryParse('$valor');

    return numero != null && numero > 0 ? numero : null;
  }
}
