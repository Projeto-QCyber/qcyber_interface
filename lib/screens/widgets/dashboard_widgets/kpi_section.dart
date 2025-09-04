import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class KpiSection extends StatelessWidget {
  final Kpis kpis;

  const KpiSection({
    super.key,
    required this.kpis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Detecções', kpis.totalDeteccoes.toString(), Icons.warning_amber, MyColors.error_qcyber)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Ações Autom.', kpis.acoesExecutadas.toString(), Icons.shield, MyColors.primary_qcyber)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Incidentes', kpis.incidentesCriados.toString(), Icons.assignment_late, Colors.orangeAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Dispositivos', kpis.dispositivosAtivos.toString(), Icons.computer, MyColors.primary_qcyber)),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 14)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: MyColors.textPrimary_qcyber, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}