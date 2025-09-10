class DispositivosAtacados {
  final String nomeDispositivo;
  final int total;

  DispositivosAtacados({ required this.nomeDispositivo, required this.total });

  factory DispositivosAtacados.fromJson(Map<String, dynamic> json) => DispositivosAtacados(
    nomeDispositivo: json["nome_dispositivo"],
    total: json["total"],
  );
}