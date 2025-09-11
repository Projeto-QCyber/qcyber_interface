import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/controllers/dashboard_action_handler.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';
import 'package:zeropoint/screens/ameacas_screen.dart';
import 'package:zeropoint/screens/device_management_screen.dart';
import 'package:zeropoint/screens/generic_history_screen.dart';
import 'package:zeropoint/services/auth_service.dart';
import 'package:zeropoint/services/dashboard_service.dart';

import 'package:zeropoint/widgets/dashboard_widgets/bar_chart_dispositivos.dart';
import 'package:zeropoint/widgets/dashboard_widgets/bar_chart_riscos.dart';
import 'package:zeropoint/widgets/dashboard_widgets/kpi_section.dart';
import 'package:zeropoint/widgets/dashboard_widgets/line_chart_detections.dart';
import 'package:zeropoint/widgets/dashboard_widgets/pie_chart_ataques.dart';

import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
// **ATUALIZADO**: O nome do arquivo foi alterado na sugestão
// import 'package:zeropoint/widgets/handlers/dashboard_action_handler.dart';


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

  // **ATUALIZADO**: Lógica de cálculo de data movida para uma função separada
  Map<String, DateTime?> _getCurrentDateRange() {
    DateTime? startDate;
    DateTime? endDate;

    switch (_selectedPreset) {
      case DateRangePreset.last24h:
      // O backend trata `null` como últimas 24h
        break;
      case DateRangePreset.last7d:
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case DateRangePreset.last30d:
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case DateRangePreset.custom:
        startDate = _customStartDate;
        // Adiciona 1 dia para incluir o dia final completo na busca da API
        endDate = _customEndDate?.add(const Duration(days: 1));
        break;
    }
    return {'startDate': startDate, 'endDate': endDate};
  }

  Future<void> _fetchData() async  {
    if (mounted) {
      final dateRange = _getCurrentDateRange();
      setState(() {
        _dashboardFuture = _dashboardService.fetchDashboardSummary(
          startDate: dateRange['startDate'],
          endDate: dateRange['endDate'],
        );
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
    final actionHandler = DashboardActionHandler(
      context: context,
      dashboardService: _dashboardService,
    );

    // **NOVO**: Obtém o intervalo de datas atual para passar para o handler
    final dateRange = _getCurrentDateRange();
    final startDate = dateRange['startDate'];
    final endDate = dateRange['endDate'];



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
              onRefresh: _fetchData,
              child: FutureBuilder<DashboardSummary>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ConnectionErrorDialog.show(context, onTryAgain: _fetchData);
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
                              // **ATUALIZADO**: Passa os parâmetros para o handler
                              onDeteccoesTapped: () => actionHandler.showDeteccoesDetails(
                                kpiCount: dashboardData.kpis.totalDeteccoes ?? 0,
                                startDate: startDate,
                                endDate: endDate,
                              ),
                              onAcoesTapped: () => actionHandler.showAcoesDetails(
                                kpiCount: dashboardData.kpis.acoesExecutadas ?? 0,
                                startDate: startDate,
                                endDate: endDate,
                              ),
                              onIncidentesTapped: () => actionHandler.showIncidentesDetails(
                                kpiCount: dashboardData.kpis.incidentesCriados ?? 0,
                                startDate: startDate,
                                endDate: endDate,
                              ),
                              onDispositivosTapped: () => actionHandler.showDispositivosDetails(
                                kpiCount: dashboardData.kpis.dispositivosAtivos ?? 0,
                              ),
                            ),
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
                            // Volume de Detecções
                            LineChartDetections(data: dashboardData.deteccoesPorHora),
                            const SizedBox(height: 24),
                            BarChartDispositivos(data: dashboardData.dispositivosAtacados),
                            const SizedBox(height: 24),
                            // DataTableSection(deteccoes: dashboardData.ultimasDeteccoes),
                            // const SizedBox(height: 40),
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
                _selectedPreset == DateRangePreset.custom && _customStartDate != null
                    ? '${DateFormat('dd/MM/yy').format(_customStartDate!)} - ${DateFormat('dd/MM/yy').format(_customEndDate!)}'
                    : 'Personalizado',
                style: TextStyle(color: _selectedPreset == DateRangePreset.custom ? MyColors.textPrimary_qcyber : MyColors.textPrimary_qcyber),
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
      label: Text(label, style: TextStyle(color: isSelected ? MyColors.textPrimary_qcyber : MyColors.textPrimary_qcyber)),
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

  final AuthService _authService = AuthService();
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
          _buildDrawerItem(
              icon: Icons.dns,
              text: "Dispositivos", // Simplificado para "Dispositivos"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeviceManagementScreen()));
              }
          ),
          _buildDrawerItem(
              icon: Icons.shield_outlined,
              text: "Histórico por Ameaça",
              onTap: () {
                Navigator.pop(context);
                // Navega para a tela de histórico em modo "Ameaça"
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericHistoryScreen(filterType: HistoryFilterType.threat)));
              }
          ),
          const Divider(color: MyColors.border_qcyber),
          _buildDrawerItem(icon: Icons.logout, text: "Sair", onTap: () {
            _authService.logout(context);
            // Navigator.pop(context);
          }),
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