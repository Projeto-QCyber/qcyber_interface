// lib/screens/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/incident_detail.dart';
import 'package:zeropoint/services/history_service.dart';
import 'package:zeropoint/services/report_service.dart';


class ReportDetailScreen extends StatefulWidget {
  final int detectionId;
  const ReportDetailScreen({super.key, required this.detectionId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final HistoryService _apiHistoryService = HistoryService();
  final ReportService  _apiService = ReportService();
  late Future<IncidentDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _apiHistoryService.getIncidentDetail(widget.detectionId);
  }

  Future<void> _downloadSpecificReport(int detectionId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Generating report..."), duration: Duration(seconds: 4)),
      );
      // Chama o novo método do serviço
      final pdfBytes = await _apiService.downloadDetectionReport(detectionId);
      await FileSaver.instance.saveFile(
        name: "detection_report_$detectionId.pdf",
        bytes: pdfBytes,
        mimeType: MimeType.pdf,
      );
    } catch(e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error downloading PDF: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: const Text("Detection Details"),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [ Padding( padding: const EdgeInsets.all(8.0), child: Image.asset(Config.logoBranca, width: 100), ), ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<IncidentDetail>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: MyColors.textSecondary_qcyber)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("No details found.", style: TextStyle(color: MyColors.textPrimary_qcyber)));
                }

                final detail = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard(detail),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Analysis (LLM)"),
                      const SizedBox(height: 8),
                      Text(detail.explicacaoLLM, style: const TextStyle(color: MyColors.textSecondary_qcyber, height: 1.5)),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Recommended Actions"),
                      const SizedBox(height: 8),
                      ...detail.acoesRecomendadas.map((acao) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text("• $acao", style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                      )),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary_qcyber,
                            foregroundColor: MyColors.textOnPrimary_qcyber,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Download Report"),
                          onPressed: () {
                            _downloadSpecificReport(detail.id);
                          },
                        ),
                      )
                    ],
                  ),
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

  Widget _buildDetailCard(IncidentDetail detail) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Attack:", detail.tipoAtaque),
            const Divider(color: MyColors.border_qcyber),
            _buildDetailRow("Device:", detail.nomeDispositivo),
            const Divider(color: MyColors.border_qcyber),
            _buildDetailRow("Date:", DateFormat('dd/MM/yyyy HH:mm').format(detail.dataDeteccao)),
            const Divider(color: MyColors.border_qcyber),
            _buildDetailRow("Response Status:", detail.statusResposta),
            const Divider(color: MyColors.border_qcyber),
            _buildDetailRow("Risk Level:", detail.nivelRisco),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: MyColors.textPrimary_qcyber, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: MyColors.textSecondary_qcyber))),
        ],
      ),
    );
  }
}