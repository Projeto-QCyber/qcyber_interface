import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard/ataque_por_tipo.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class PieChartAtaques extends StatelessWidget {
  final List<AtaquePorTipo> ataques;
  final int touchedIndex;
  final Function(int) onTouch;

  const PieChartAtaques({
    super.key,
    required this.ataques,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final pieColors = [ MyColors.chart1_qcyber, MyColors.chart2_qcyber, MyColors.chart3_qcyber, Colors.orangeAccent, MyColors.primary_qcyber.withOpacity(0.7) ];
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tipos de Ameaças", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            if (ataques.isEmpty)
              const Center(heightFactor: 5, child: Text('Nenhum dado.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          onTouch(-1);
                          return;
                        }
                        onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(ataques.length, (i) {
                      final isTouched = i == touchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 70.0 : 60.0;
                      final ataque = ataques[i];
                      String displayTitle = ataque.nomeAtaque.length > 8 ? '${ataque.nomeAtaque.substring(0, 5)}..' : ataque.nomeAtaque;

                      return PieChartSectionData(
                        color: pieColors[i % pieColors.length],
                        value: ataque.total.toDouble(),
                        title: displayTitle.replaceAll('_', '\n'),
                        radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)]),
                        badgeWidget: isTouched ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(8),),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ataque.nomeAtaque.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              SizedBox(width: 150, child: Text(ataque.descricao, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 3, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ) : null,
                        badgePositionPercentageOffset: isTouched ? 1.05 : 0.98,
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}