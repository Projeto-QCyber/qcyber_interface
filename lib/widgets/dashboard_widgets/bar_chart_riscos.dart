import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class BarChartRiscos extends StatelessWidget {
  final List<IncidentesPorRisco> data;

  const BarChartRiscos({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final riskColors = {
      'Crítico': MyColors.error_qcyber,
      'Alto': Colors.orangeAccent,
      'Médio': MyColors.chart3_qcyber,
      'Baixo': MyColors.primary_qcyber
    };

    if (data.isEmpty) {
      return Card(
        color: MyColors.card_qcyber,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: MyColors.border_qcyber)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Incidentes por Risco",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary_qcyber)),
              const SizedBox(height: 20),
              const Center(
                  heightFactor: 5,
                  child: Text('Nenhum incidente.',
                      style: TextStyle(color: MyColors.textSecondary_qcyber))),
            ],
          ),
        ),
      );
    }

    final maxY = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    double interval = (maxY / 4).ceilToDouble();
    if (interval < 1) interval = 1;

    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Incidentes por Risco",
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
                  // SEÇÃO CORRIGIDA
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      // O parâmetro correto é 'getTooltipColor'
                      getTooltipColor: (group) {
                        return Colors.black.withOpacity(0.8);
                      },
                      tooltipRoundedRadius: 8, // Borda arredondada para o tooltip
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
                        )),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= data.length) {
                                return const Text('');
                              }
                              return Text(
                                  data[value.toInt()]
                                      .nivelRisco
                                      .substring(0, 3),
                                  style: const TextStyle(
                                      color: MyColors.textSecondary_qcyber,
                                      fontSize: 10));
                            })),
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final barColor =
                        riskColors[data[i].nivelRisco] ?? Colors.grey;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].total.toDouble(),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              barColor.withOpacity(0.7),
                              barColor,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
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