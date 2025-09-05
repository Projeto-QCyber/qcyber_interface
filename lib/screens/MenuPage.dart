import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';
import 'package:zeropoint/screens/ameacas_screen.dart';
import 'package:zeropoint/screens/dispositivos_screen.dart';
import 'package:zeropoint/services/dashboard_service.dart';

// Imports dos widgets extraídos
// import 'package:zeropoint/screens/widgets/dashboard_widgets/bar_chart_dispositivos.dart';
import 'package:zeropoint/widgets/dashboard_widgets/bar_chart_dispositivos.dart';
import 'package:zeropoint/widgets/dashboard_widgets/bar_chart_riscos.dart';
import 'package:zeropoint/widgets/dashboard_widgets/data_table_section.dart';
import 'package:zeropoint/widgets/dashboard_widgets/kpi_section.dart';
import 'package:zeropoint/widgets/dashboard_widgets/line_chart_detections.dart';
import 'package:zeropoint/widgets/dashboard_widgets/pie_chart_ataques.dart';

// Imports dos diálogos e do nosso Controller/Handler
import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
import 'package:zeropoint/controllers/dashboard_action_handler.dart';


enum DateRangePreset { last24h, last7d, last30d, custom }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardSummary> _dashboardFuture;
  int _touchedIndex = -1;

  DateRangePreset _selectedPreset = DateRangePreset.last24h;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async  {
    if (mounted) {
      DateTime? startDate;
      DateTime? endDate;

      if (_selectedPreset == DateRangePreset.last7d) {
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 7));
      } else if (_selectedPreset == DateRangePreset.last30d) {
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 30));
      } else if (_selectedPreset == DateRangePreset.custom) {
        startDate = _customStartDate;
        endDate = _customEndDate?.add(const Duration(days: 1));
      }

      setState(() {
        _dashboardFuture = _dashboardService.fetchDashboardSummary(startDate: startDate, endDate: endDate);
      });
    }
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.primary_qcyber,
              onPrimary: MyColors.textOnPrimary_qcyber,
              onSurface: MyColors.textPrimary_qcyber,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = DateRangePreset.custom;
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // O Handler é criado aqui, com o contexto e serviço necessários
    final actionHandler = DashboardActionHandler(
      context: context,
      dashboardService: _dashboardService,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('QCyber Dashboard'),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [ Padding( padding: const EdgeInsets.all(8.0), child: Image.asset(Config.logoBranca, width: 100), ), ],
      ),
      drawer: _buildDrawer(context),
      backgroundColor: MyColors.background_qcyber,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: FutureBuilder<DashboardSummary>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ConnectionErrorDialog.show(
                        context,
                        onTryAgain: _fetchData, // Agora os tipos são compatíveis!
                      );
                    });
                    return const Center(child: Text('Tentando reconectar...', style: TextStyle(color: MyColors.textSecondary_qcyber)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
                  if (!snapshot.hasData) { return const Center(child: Text('Nenhum dado encontrado.', style: TextStyle(color: MyColors.textPrimary_qcyber))); }

                  final dashboardData = snapshot.data!;
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDateFilter(),
                            const SizedBox(height: 16),
                            KpiSection(
                              kpis: dashboardData.kpis,
                              onDeteccoesTapped: actionHandler.showDeteccoesDetails,
                              onAcoesTapped: actionHandler.showAcoesDetails,
                              onIncidentesTapped: actionHandler.showIncidentesDetails,
                              onDispositivosTapped: actionHandler.showDispositivosDetails,
                            ),
                            const SizedBox(height: 24),
                            LineChartDetections(data: dashboardData.deteccoesPorHora),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: PieChartAtaques(
                                      ataques: dashboardData.ataquesPorTipo,
                                      touchedIndex: _touchedIndex,
                                      onTouch: (index) => setState(() => _touchedIndex = index),
                                    )
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: BarChartRiscos(data: dashboardData.incidentesPorRisco)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            BarChartDispositivos(data: dashboardData.dispositivosAtacados),
                            const SizedBox(height: 24),
                            DataTableSection(deteccoes: dashboardData.ultimasDeteccoes),
                            const SizedBox(height: 40),
                          ],
                        ),
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
              ),
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

  // --- Widgets de Construção da UI (agora são apenas helpers menores) ---

  Widget _buildDateFilter() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterChip(DateRangePreset.last24h, 'Últimas 24h'),
            const SizedBox(width: 8),
            _buildFilterChip(DateRangePreset.last7d, 'Últimos 7 dias'),
            const SizedBox(width: 8),
            _buildFilterChip(DateRangePreset.last30d, 'Últimos 30 dias'),
            const SizedBox(width: 8),
            ActionChip(
              label: Text(
                _selectedPreset == DateRangePreset.custom
                    ? '${DateFormat('dd/MM/yy').format(_customStartDate!)} - ${DateFormat('dd/MM/yy').format(_customEndDate!)}'
                    : 'Personalizado',
                style: TextStyle(color: _selectedPreset == DateRangePreset.custom ? Colors.white : MyColors.primary_qcyber),
              ),
              backgroundColor: _selectedPreset == DateRangePreset.custom ? MyColors.primary_qcyber : MyColors.card_qcyber,
              onPressed: () => _selectCustomDateRange(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: MyColors.border_qcyber)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(DateRangePreset preset, String label) {
    final isSelected = _selectedPreset == preset;
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : MyColors.primary_qcyber)),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _selectedPreset = preset);
          _fetchData();
        }
      },
      backgroundColor: MyColors.card_qcyber,
      selectedColor: MyColors.primary_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: MyColors.border_qcyber)),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: MyColors.card_qcyber,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: MyColors.primary_qcyber),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(Config.logoBranca, height: 40),
                const SizedBox(height: 16),
                const Text('Menu de Navegação', style: TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20)),
              ],
            ),
          ),
          _buildDrawerItem(icon: Icons.dashboard, text: "Dashboard", onTap: () { Navigator.pop(context); }),
          _buildDrawerItem(icon: Icons.devices, text: "Dispositivos", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DispositivosScreen()));
          }),
          _buildDrawerItem(icon: Icons.security, text: "Ameaças", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AmeacasScreen()));
          }),
          const Divider(color: MyColors.border_qcyber),
          _buildDrawerItem(icon: Icons.logout, text: "Sair", onTap: () { Navigator.pop(context); }),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: MyColors.textSecondary_qcyber),
      title: Text(text, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
      onTap: onTap,
    );
  }
}