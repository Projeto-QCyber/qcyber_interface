import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class LineChartDetections extends StatelessWidget {
  final List<DeteccoesPorHora> data;

  const LineChartDetections({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
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
              const Text("Volume de Detecções",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary_qcyber)),
              const SizedBox(height: 20),
              Center(
                  heightFactor: 5,
                  child: Text(
                      data.isEmpty
                          ? 'Nenhum dado de volume para exibir.'
                          : 'Dados insuficientes para formar uma linha.',
                      style:
                      const TextStyle(color: MyColors.textSecondary_qcyber))),
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
            const Text("Volume de Detecções",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxY.toDouble(),
                  // NOVA SEÇÃO ADICIONADA PARA CONFIGURAR O TOOLTIP
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          Colors.black.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          // Para mostrar a data/hora no tooltip
                          final index = flSpot.x.toInt();
                          final date = data[index].hora.toLocal();
                          final format = DateFormat('dd/MM HH:mm');

                          return LineTooltipItem(
                            '${flSpot.y.toInt()}\n', // Valor Y (total)
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: format.format(date), // Valor X (data/hora)
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            textAlign: TextAlign.center,
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
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
                          interval: (data.length / 5).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= data.length) return const SizedBox.shrink();
                            final totalDuration =
                            data.last.hora.difference(data.first.hora);
                            final format = totalDuration.inDays > 1
                                ? DateFormat('dd/MM')
                                : DateFormat('HH:mm');
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(format.format(data[index].hora.toLocal()),
                                  style: const TextStyle(
                                      color: MyColors.textSecondary_qcyber,
                                      fontSize: 10)),
                            );
                          },
                        )),
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: MyColors.border_qcyber)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < data.length; i++)
                          FlSpot(i.toDouble(), data[i].total.toDouble())
                      ],
                      isCurved: true,
                      color: MyColors.chart1_qcyber,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: MyColors.chart1_qcyber.withOpacity(0.2)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}