// lib/screens/generic_history_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';

import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/detection_history_item.dart';
import 'package:zeropoint/objetos/filter_item.dart';
import 'package:zeropoint/services/history_service.dart';
import 'package:zeropoint/services/report_service.dart';
// Removemos: import 'report_detail_screen.dart'; (O Router resolve isso)

enum HistoryFilterType { device, threat, all } // Adicionei 'all' como fallback seguro

class GenericHistoryScreen extends StatefulWidget {
  final HistoryFilterType filterType;
  final int? initialSelectedItemId;

  const GenericHistoryScreen({
    super.key,
    this.filterType = HistoryFilterType.threat, // Valor padrão
    this.initialSelectedItemId,
  });

  @override
  State<GenericHistoryScreen> createState() => _GenericHistoryScreenState();
}

class _GenericHistoryScreenState extends State<GenericHistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final ReportService _reportService = ReportService();

  List<FilterItem>? _filterOptions;
  FilterItem? _selectedFilterItem;
  Future<List<DetectionHistoryItem>>? _historyFuture;
  bool _isLoadingFilter = false;

  @override
  void initState() {
    super.initState();
    _fetchFilterOptions();
  }

  String get _screenTitle => "History by Threat";
  String get _filterLabel => "Select a Threat";

  Future<void> _fetchFilterOptions() async {
    setState(() => _isLoadingFilter = true);
    try {
      final type = "threat-types";
      final options = await _historyService.getFilterOptions(type);
      if (mounted) {
        setState(() {
          _filterOptions = options;
          // Lógica de pré-seleção mantida
          if (widget.initialSelectedItemId != null) {
            try {
              _selectedFilterItem = _filterOptions?.firstWhere(
                      (item) => item.id == widget.initialSelectedItemId
              );
              if (_selectedFilterItem != null) {
                _fetchHistory(_selectedFilterItem!.id);
              }
            } catch (e) {
              print("Item inicial com ID ${widget.initialSelectedItemId} não encontrado na lista de filtros.");
            }
          }
        });
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading filters: $e"), backgroundColor: MyColors.error_qcyber));
    } finally {
      if (mounted) setState(() => _isLoadingFilter = false);
    }
  }

  void _fetchHistory(int id) {
    final type = "by-threat";
    setState(() {
      _historyFuture = _historyService.getHistory(type, id);
    });
  }

  Future<void> _downloadThreatReport() async {
    if (_selectedFilterItem == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Generating report...")),
      );
      final pdfBytes = await _reportService.downloadThreatReport(_selectedFilterItem!.id);
      await FileSaver.instance.saveFile(
        name: "threat_report_${_selectedFilterItem!.id}.pdf",
        bytes: pdfBytes,
        mimeType: MimeType.pdf,
      );
    } catch(e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e"), backgroundColor: MyColors.error_qcyber),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [ Padding( padding: const EdgeInsets.all(8.0), child: Image.asset(Config.logoBranca, width: 100), ), ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: _buildFilter()),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text("Generate PDF"),
                  onPressed: _selectedFilterItem == null ? null : _downloadThreatReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary_qcyber,
                    foregroundColor: MyColors.textOnPrimary_qcyber,
                    disabledBackgroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
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

  Widget _buildFilter() {
    return DropdownButtonFormField<FilterItem>(
      value: _selectedFilterItem,
      hint: Text(
        _isLoadingFilter ? "Loading filters..." : _filterLabel,
        style: const TextStyle(color: MyColors.textSecondary_qcyber),
      ),
      isExpanded: true,
      items: _filterOptions?.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.nome, overflow: TextOverflow.ellipsis));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedFilterItem = value);
          _fetchHistory(value.id);
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: MyColors.card_qcyber,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.border_qcyber)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.border_qcyber)),
      ),
      dropdownColor: MyColors.card_qcyber,
      style: const TextStyle(color: MyColors.textPrimary_qcyber),
    );
  }

  Widget _buildContent() {
    if (_selectedFilterItem == null) {
      return const Center(child: Text("Select an item from the filter above to begin.", style: TextStyle(color: MyColors.textSecondary_qcyber)));
    }
    if (_historyFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<DetectionHistoryItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: MyColors.textSecondary_qcyber)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No results found.", style: const TextStyle(color: MyColors.textPrimary_qcyber)));
        }

        final historyItems = snapshot.data!;
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 60),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Card(
                  color: MyColors.card_qcyber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    // ATUALIZADO: Navegação via rota nomeada para a tela de Report Detail
                    onTap: () => context.push('/reports/${item.id}'),
                    child: ListTile(
                      leading: const Icon(Icons.shield_outlined, color: MyColors.primary_qcyber),
                      title: Text(item.tipoAtaque, style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
                      subtitle: Text(item.nomeDispositivo, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                      trailing: Text(DateFormat('dd/MM HH:mm').format(item.dataDeteccao), style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, height: 50.0,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [ MyColors.background_qcyber.withOpacity(0.0), MyColors.background_qcyber, ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}