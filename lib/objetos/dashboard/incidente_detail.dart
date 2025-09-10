class IncidenteDetail {
  final String titulo;
  final String nivelRisco;
  // final String nomeDispositivo;
  final DateTime dataCriacao;

  IncidenteDetail({required this.titulo, required this.nivelRisco, required this.dataCriacao});

  factory IncidenteDetail.fromJson(Map<String, dynamic> json) => IncidenteDetail(
    titulo: json["titulo"],
    nivelRisco: json["nivel_risco"],
    dataCriacao: DateTime.parse(json["data_criacao"]),
  );
}
