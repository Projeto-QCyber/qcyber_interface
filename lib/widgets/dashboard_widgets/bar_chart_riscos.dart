import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zeropoint/_Core/enums/nivel_risco_enum.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard/incidentes_por_risco.dart';

class BarChartRiscos extends StatelessWidget {
  final List<IncidentesPorRisco> data;

  const BarChartRiscos({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // --- Consolidar os dados por nivelRisco ---
    final Map<NivelRisco, int> agrupado = {};
    for (var d in data) {
      agrupado[d.nivelRisco] = (agrupado[d.nivelRisco] ?? 0) + d.total;
    }
    final dataAgrupada = agrupado.entries
        .map((e) => IncidentesPorRisco(nivelRisco: e.key, total: e.value))
        .toList();

    if (dataAgrupada.isEmpty) {
      return Card(
        color: MyColors.card_qcyber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: MyColors.border_qcyber),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Incidents by Risk",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary_qcyber)),
              SizedBox(height: 20),
              Center(
                heightFactor: 5,
                child: Text('No incidents.',
                    style: TextStyle(color: MyColors.textSecondary_qcyber)),
              ),
            ],
          ),
        ),
      );
    }

    final maxY =
    dataAgrupada.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    double interval = (maxY / 4).ceilToDouble();
    if (interval < 1) interval = 1;

    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: MyColors.border_qcyber),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Incidents by Risk",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY.toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          Colors.black.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toInt().toString(),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(
                                  color: MyColors.textSecondary_qcyber,
                                  fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= dataAgrupada.length) {
                            return const Text('');
                          }

                          final riskName =
                              dataAgrupada[value.toInt()].nivelRisco.displayName;

                          return Text(
                              riskName.length > 3
                                  ? riskName.substring(0, 3)
                                  : riskName,
                              style: const TextStyle(
                                  color: MyColors.textSecondary_qcyber,
                                  fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(dataAgrupada.length, (i) {
                    final barColor =
                        dataAgrupada[i].nivelRisco.backgroundColor;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: dataAgrupada[i].total.toDouble(),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          color: barColor, /// COR NORMAL

                          /// COR COM DEGRADE
                          // gradient: LinearGradient(
                          //   colors: [
                          //     barColor.withOpacity(0.7),
                          //     barColor,
                          //   ],
                          //   begin: Alignment.bottomCenter,
                          //   end: Alignment.topCenter,
                          // ),
                        ),
                      ],
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