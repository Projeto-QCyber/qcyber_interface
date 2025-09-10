class Kpis {
  final int totalDeteccoes;
  final int acoesExecutadas;
  final int dispositivosAtivos;
  final int incidentesCriados;

  Kpis({
    required this.totalDeteccoes,
    required this.acoesExecutadas,
    required this.dispositivosAtivos,
    required this.incidentesCriados,
  });

  factory Kpis.fromJson(Map<String, dynamic> json) => Kpis(
    totalDeteccoes: json["total_deteccoes"],
    acoesExecutadas: json["acoes_executadas"],
    dispositivosAtivos: json["dispositivos_ativos"],
    incidentesCriados: json["incidentes_criados"],
  );
}