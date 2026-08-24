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
}