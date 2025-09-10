import 'package:zeropoint/_Core/enums/nivel_risco_enum.dart';

class IncidentesPorRisco {
  final NivelRisco nivelRisco;
  final int total;

  IncidentesPorRisco({ required this.nivelRisco, required this.total });

  factory IncidentesPorRisco.fromJson(Map<String, dynamic> json) {
    return IncidentesPorRisco(
      nivelRisco: NivelRisco.fromString(json['nivel_risco'] as String? ?? ''),
      total: json['total'],
    );
  }
}
