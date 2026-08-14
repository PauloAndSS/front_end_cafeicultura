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

  /// Envelope das rotas de atividade, que batizam os contadores de outro jeito
  /// e põem a lista sob uma chave nomeada pelo recurso:
  ///
  /// ```json
  /// // /tratosculturais/propriedade/{id}?status=...&pagina=N
  /// { "total": 145, "paginaAtual": 1, "totalPaginas": 6, "tratos": [...] }
  /// ```
  ///
  /// Uma factory a mais em vez de um segundo DTO de paginação: quem consome só
  /// precisa de [data] e [totalPaginas] para saber se ainda há página. O
  /// `totalRegistros ?? total` cobre os dois nomes de contador já vistos no
  /// backend — não é tentativa às cegas.
  ///
  /// **Só para o caso paginado.** As rotas temporais (`/eventos/propriedade/{id}`
  /// e `/tratosculturais/propriedade/{id}` sem `pagina`) devolvem o mesmo
  /// envelope sem contador nenhum, e passam por `BaseService.extrairListaNomeada`
  /// — fabricar aqui um `totalPaginas: 1` inventaria uma paginação inexistente.
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
}