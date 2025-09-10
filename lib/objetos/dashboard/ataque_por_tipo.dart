class AtaquePorTipo {
  final String nomeAtaque;
  final int total;
  final String descricao;

  AtaquePorTipo({
    required this.nomeAtaque,
    required this.total,
    required this.descricao,
  });

  factory AtaquePorTipo.fromJson(Map<String, dynamic> json) => AtaquePorTipo(
    nomeAtaque: json["nome_ataque"],
    total: json["total"],
    descricao: json["descricao"],
  );
}