class AcaoDetail {
  final DateTime dataAcaoExecutada;
  final String? acaoParametro;
  final String nomeAcao;

  AcaoDetail({required this.dataAcaoExecutada, this.acaoParametro, required this.nomeAcao});

  factory AcaoDetail.fromJson(Map<String, dynamic> json) => AcaoDetail(
    dataAcaoExecutada: DateTime.parse(json["data_acao_executada"]),
    acaoParametro: json["acao_parametro"],
    nomeAcao: json["nome_acao"],
  );
}
