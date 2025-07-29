/// Representa o resumo dos KPIs recebidos da API.
class KpiSummary {
  final int totalAlerts24h;
  final double avgAccuracy24h;
  final int dispositivosProtegidos;
  final int ameacasBloqueadas;

  KpiSummary({
    required this.totalAlerts24h,
    required this.avgAccuracy24h,
    required this.dispositivosProtegidos,
    required this.ameacasBloqueadas,
  });

  factory KpiSummary.fromJson(Map<String, dynamic> json) {
    return KpiSummary(
      totalAlerts24h: json['total_alerts_24h'],
      avgAccuracy24h: (json['avg_accuracy_24h'] as num).toDouble(),
      dispositivosProtegidos: json['dispositivos_protegidos'],
      ameacasBloqueadas: json['ameacas_bloqueadas'],
    );
  }
}
