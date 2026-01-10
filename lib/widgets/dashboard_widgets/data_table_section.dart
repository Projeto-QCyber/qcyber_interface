import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard/ultima_deteccao.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class DataTableSection extends StatelessWidget {
  final List<UltimaDeteccao> deteccoes;

  const DataTableSection({
    super.key,
    required this.deteccoes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Detection History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 8),
            if(deteccoes.isEmpty)
              const Center(heightFactor: 3, child: Text('No recent detections to display for this period.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber),
                  dataTextStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
                  columns: const [
                    DataColumn(label: Text('Date/Time')),
                    DataColumn(label: Text('Device')),
                    DataColumn(label: Text('Threat')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: deteccoes.map((deteccao) => DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd/MM HH:mm').format(deteccao.dataDeteccao.toLocal()))),
                      DataCell(Text(deteccao.nomeDispositivo)),
                      DataCell(Text(deteccao.tipoAtaque)),
                      DataCell(Text(deteccao.statusResposta)),
                    ],
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}