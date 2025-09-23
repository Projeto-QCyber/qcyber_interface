import 'dart:convert';

import 'package:zeropoint/_core/enums/nivel_risco_enum.dart';
import 'package:zeropoint/objetos/dashboard/ataque_por_tipo.dart';
import 'package:zeropoint/objetos/dashboard/deteccoes_por_hora.dart';
import 'package:zeropoint/objetos/dashboard/dispositivos_atacados.dart';
import 'package:zeropoint/objetos/dashboard/incidentes_por_risco.dart';
import 'package:zeropoint/objetos/dashboard/kpis.dart';
import 'package:zeropoint/objetos/dashboard/ultima_deteccao.dart';

// Função para decodificar o JSON de forma segura
DashboardSummary dashboardSummaryFromJson(String str) => DashboardSummary.fromJson(json.decode(str));

class DashboardSummary {
  final Kpis kpis;
  final List<AtaquePorTipo> ataquesPorTipo;
  final List<UltimaDeteccao> ultimasDeteccoes;
  final List<DeteccoesPorHora> deteccoesPorHora;
  final List<DispositivosAtacados> dispositivosAtacados;
  final List<IncidentesPorRisco> incidentesPorRisco;


  DashboardSummary({
    required this.kpis,
    required this.ataquesPorTipo,
    required this.ultimasDeteccoes,
    required this.deteccoesPorHora,
    required this.dispositivosAtacados,
    required this.incidentesPorRisco,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
    kpis: Kpis.fromJson(json["kpis"]),
    ataquesPorTipo: List<AtaquePorTipo>.from(json["ataques_por_tipo"].map((x) => AtaquePorTipo.fromJson(x))),
    ultimasDeteccoes: List<UltimaDeteccao>.from(json["ultimas_deteccoes"].map((x) => UltimaDeteccao.fromJson(x))),
    deteccoesPorHora: List<DeteccoesPorHora>.from(json["deteccoes_por_hora"].map((x) => DeteccoesPorHora.fromJson(x))),
    dispositivosAtacados: List<DispositivosAtacados>.from(json["dispositivos_atacados"].map((x) => DispositivosAtacados.fromJson(x))),
    incidentesPorRisco: List<IncidentesPorRisco>.from(json["incidentes_por_risco"].map((x) => IncidentesPorRisco.fromJson(x))),

  );
}
