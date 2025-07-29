class Dispositivo {
  final int id;
  final String nome;
  final String host;
  final String? localizacao;
  final String status;
  final DateTime dataCadastro;

  Dispositivo({
    required this.id,
    required this.nome,
    required this.host,
    this.localizacao,
    required this.status,
    required this.dataCadastro,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: json['id'],
      nome: json['nome'],
      host: json['host'],
      localizacao: json['localizacao'],
      status: json['status'],
      dataCadastro: DateTime.parse(json['data_cadastro']),
    );
  }
}
