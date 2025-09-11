class DetectionHistoryItem {
  final int id;
  final DateTime dataDeteccao;
  final String tipoAtaque;
  final String nomeDispositivo;
  final String statusResposta;

  DetectionHistoryItem({
    required this.id,
    required this.dataDeteccao,
    required this.tipoAtaque,
    required this.nomeDispositivo,
    required this.statusResposta,
  });

  factory DetectionHistoryItem.fromJson(Map<String, dynamic> json) {
    return DetectionHistoryItem(
      id: json['id'],
      dataDeteccao: DateTime.parse(json['data_deteccao']),
      tipoAtaque: json['tipo_ataque'],
      nomeDispositivo: json['nome_dispositivo'],
      statusResposta: json['status_resposta'],
    );
  }
}
