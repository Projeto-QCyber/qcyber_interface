import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard/dispositivos_atacados.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class BarChartDispositivos extends StatelessWidget {
  final List<DispositivosAtacados> data;

  const BarChartDispositivos({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Most Attacked Devices", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            if (data.isEmpty)
              const Center(heightFactor: 5, child: Text('No devices attacked in this period.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              ...data.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    // ALTERAÇÃO 2: Nome do dispositivo agora é flexível
                    Expanded(
                        flex: 1, // Ocupa 2 partes do espaço flexível
                        child: Text(item.nomeDispositivo, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MyColors.textSecondary_qcyber))),
                    // Adicionado um pequeno espaço entre o nome e a barra
                    // const SizedBox(width: 2),
                    // ALTERAÇÃO 2: A barra também é flexível
                    Expanded(
                      flex: 3, // Ocupa 3 partes do espaço flexível (maior que o nome)
                      child: LinearProgressIndicator(
                        value: item.total / (data.first.total > 0 ? data.first.total : 1),
                        backgroundColor: MyColors.border_qcyber,
                        valueColor: const AlwaysStoppedAnimation<Color>(MyColors.chart2_qcyber),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // ALTERAÇÃO 1: Adiciona a margem entre a barra e o valor
                    const SizedBox(width: 8),
                    SizedBox(width: 50, child: Text(' ${item.total}', style: const TextStyle(color: MyColors.textPrimary_qcyber, fontWeight: FontWeight.bold))),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}