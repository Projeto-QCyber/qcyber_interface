class DeteccoesPorHora {
  final DateTime hora;
  final int total;

  DeteccoesPorHora({ required this.hora, required this.total });

  factory DeteccoesPorHora.fromJson(Map<String, dynamic> json) => DeteccoesPorHora(
    hora: DateTime.parse(json["hora"]),
    total: json["total"],
  );
}
