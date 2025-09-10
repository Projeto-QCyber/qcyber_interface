class DispositivoDetail {
  final String nome;
  final String host;

  DispositivoDetail({required this.nome, required this.host});

  factory DispositivoDetail.fromJson(Map<String, dynamic> json) => DispositivoDetail(
    nome: json["nome"],
    host: json["host"],
  );
}