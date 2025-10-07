// lib/screens/device_history_detail_screen.dart (Completo e Final)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:file_saver/file_saver.dart';
import 'package:zeropoint/objetos/detection_history_item.dart';
import 'package:zeropoint/objetos/dispositivo.dart';
import 'package:zeropoint/services/history_service.dart';
import 'package:zeropoint/services/report_service.dart';
import 'report_detail_screen.dart';

class DeviceHistoryDetailScreen extends StatefulWidget {
  final Dispositivo dispositivo;
  const DeviceHistoryDetailScreen({super.key, required this.dispositivo});

  @override
  State<DeviceHistoryDetailScreen> createState() => _DeviceHistoryDetailScreenState();
}

class _DeviceHistoryDetailScreenState extends State<DeviceHistoryDetailScreen> {
  // CORREÇÃO: Instanciamos os DOIS serviços necessários
  final HistoryService _historyService = HistoryService();
  final ReportService _reportService = ReportService();

  late Future<List<DetectionHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Usamos o HistoryService para buscar o histórico
    _historyFuture = _historyService.getHistory("by-device", widget.dispositivo.id);
  }

  Future<void> _downloadReport() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Generating report...")),
      );
      // CORREÇÃO: Chamamos a função a partir do ReportService
      final pdfBytes = await _reportService.downloadDeviceReport(widget.dispositivo.id);

      await FileSaver.instance.saveFile(
        name: "device_report_${widget.dispositivo.id}.pdf",
        bytes: pdfBytes,
        mimeType: MimeType.pdf,
      );
    } catch(e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: Text(widget.dispositivo.nome),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [ Padding( padding: const EdgeInsets.all(8.0), child: Image.asset(Config.logoBranca, width: 100), ), ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<DetectionHistoryItem>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: MyColors.textSecondary_qcyber)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No detections found for this device.", style: TextStyle(color: MyColors.textPrimary_qcyber)));
                }

                final historyItems = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return Card(
                      color: MyColors.card_qcyber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ReportDetailScreen(detectionId: item.id),
                        )),
                        child: ListTile(
                          leading: const Icon(Icons.shield_outlined, color: MyColors.primary_qcyber),
                          title: Text(item.tipoAtaque, style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
                          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(item.dataDeteccao), style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                          trailing: Text(item.statusResposta, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: MyColors.card_qcyber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Detection History", style: TextStyle(color: MyColors.textPrimary_qcyber, fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text("Generate PDF"),
                onPressed: _downloadReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary_qcyber,
                  foregroundColor: MyColors.textOnPrimary_qcyber,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: MyColors.border_qcyber),
          Text("Host: ${widget.dispositivo.host} | Location: ${widget.dispositivo.localizacao ?? 'N/A'}", style: const TextStyle(color: MyColors.textSecondary_qcyber)),
        ],
      ),
    );
  }
}