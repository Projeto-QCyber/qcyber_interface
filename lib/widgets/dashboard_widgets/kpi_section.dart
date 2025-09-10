import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard/kpis.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class KpiSection extends StatelessWidget {
  final Kpis kpis;
  // NOVAS PROPRIEDADES: Funções de callback para cada clique
  final VoidCallback onDeteccoesTapped;
  final VoidCallback onAcoesTapped;
  final VoidCallback onIncidentesTapped;
  final VoidCallback onDispositivosTapped;

  const KpiSection({
    super.key,
    required this.kpis,
    required this.onDeteccoesTapped,
    required this.onAcoesTapped,
    required this.onIncidentesTapped,
    required this.onDispositivosTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Detecções', kpis.totalDeteccoes.toString(), Icons.warning_amber, MyColors.error_qcyber, onTap: onDeteccoesTapped)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Ações Autom.', kpis.acoesExecutadas.toString(), Icons.shield, MyColors.primary_qcyber, onTap: onAcoesTapped)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Incidentes', kpis.incidentesCriados.toString(), Icons.assignment_late, Colors.orangeAccent, onTap: onIncidentesTapped)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Dispositivos', kpis.dispositivosAtivos.toString(), Icons.computer, MyColors.primary_qcyber, onTap: onDispositivosTapped)),
      ],
    );
  }

  // ATUALIZADO: O método agora aceita um parâmetro onTap
  Widget _buildKpiCard(String title, String value, IconData icon, Color color, {required VoidCallback onTap}) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      // ATUALIZADO: Usando InkWell para dar o efeito de clique
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}