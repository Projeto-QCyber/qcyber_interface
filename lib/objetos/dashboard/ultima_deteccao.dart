class UltimaDeteccao {
  final int id;
  final DateTime dataDeteccao;
  final String nomeDispositivo;
  final String tipoAtaque;
  final String statusResposta;

  UltimaDeteccao({
    required this.id,
    required this.dataDeteccao,
    required this.nomeDispositivo,
    required this.tipoAtaque,
    required this.statusResposta,
  });

  factory UltimaDeteccao.fromJson(Map<String, dynamic> json) => UltimaDeteccao(
    id: json["id"],
    dataDeteccao: DateTime.parse(json["data_deteccao"]),
    nomeDispositivo: json["nome_dispositivo"],
    tipoAtaque: json["tipo_ataque"],
    statusResposta: json["status_resposta"],
  );
}
