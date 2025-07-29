import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/analise.dart';
import 'package:zeropoint/objetos/kpi_summary.dart';
import 'package:zeropoint/objetos/paginated_analyses.dart';
import 'package:zeropoint/screens/ameacas_screen.dart';
import 'package:zeropoint/screens/dispositivos_screen.dart';
import 'package:zeropoint/services/dashboard_service.dart';

// Enum para controlar os presets de data
enum DateRangePreset { last24h, last7d, last30d, custom }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final DashboardService _dashboardService = DashboardService();
  // Futuros separados para KPIs e para a lista de análises
  late Future<KpiSummary> _kpisFuture;
  late Future<PaginatedAnalyses> _analysesFuture;
  Timer? _timer;

  // Estado para o filtro de data
  DateRangePreset _selectedPreset = DateRangePreset.last24h;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Faz a primeira busca de dados
    // Configura o timer para atualizar os dados a cada 3 minutos
    _timer = Timer.periodic(const Duration(minutes: 3), (Timer t) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  // Função unificada para buscar todos os dados do dashboard
  void _fetchData() {
    if (mounted) {
      DateTime? startDate;
      DateTime? endDate;

      // Define as datas com base no preset selecionado
      if (_selectedPreset == DateRangePreset.last7d) {
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 7));
      } else if (_selectedPreset == DateRangePreset.last30d) {
        endDate = DateTime.now();
        startDate = endDate.subtract(const Duration(days: 30));
      } else if (_selectedPreset == DateRangePreset.custom) {
        startDate = _customStartDate;
        endDate = _customEndDate;
      }
      // Se for last24h, não enviamos nada e a API usa o seu padrão

      setState(() {
        print("Buscando dados para o período selecionado... (${DateTime.now()})");
        _kpisFuture = _dashboardService.fetchKpis(startDate: startDate, endDate: endDate);
        _analysesFuture = _dashboardService.fetchAnalises(startDate: startDate, endDate: endDate);
      });
    }
  }

  // Função para abrir o seletor de datas personalizado
  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
      // <<< MUDANÇA AQUI: Adicionado um builder para personalizar o tema >>>
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.primary_qcyber, // Cor principal (cabeçalho, seleção)
              onPrimary: MyColors.textOnPrimary_qcyber, // Cor do texto sobre a cor principal
              onSurface: MyColors.textPrimary_qcyber, // Cor do texto dos dias
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColors.primary_qcyber, // Cor dos botões "OK", "Cancelar"
              ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('QCyber Dashboard'),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Config.logoBranca, width: 100),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      backgroundColor: MyColors.background_qcyber,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Usamos RefreshIndicator para permitir que o usuário puxe para atualizar
                RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateFilter(), // Seletor de datas
                        const SizedBox(height: 16),
                        _buildKpiSection(),
                        const SizedBox(height: 24),
                        _buildMainContentSection(),
                        const SizedBox(height: 40), // Espaço para o fade
                      ],
                    ),
                  ),
                ),
                // Efeito de fade na parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50.0,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            MyColors.background_qcyber.withOpacity(0.0),
                            MyColors.background_qcyber,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rodapé com a logo
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

  // --- Widgets de Construção da UI ---

  Widget _buildDateFilter() {
    // ALTERADO: Envolvido com um Center para centralizar o conteúdo
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Garante centralização
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
                const Text(
                  'Menu de Navegação',
                  style: TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20),
                ),
              ],
            ),
          ),
          _buildDrawerItem(icon: Icons.devices, text: "Dispositivos", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DispositivosScreen()));
          }),
          _buildDrawerItem(icon: Icons.security, text: "Ameaças", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AmeacasScreen()));
          }),

          _buildDrawerItem(icon: Icons.chat_bubble, text: "LLM (Assistente)", onTap: () { Navigator.pop(context); }),
          _buildDrawerItem(icon: Icons.people_alt, text: "Agentes", onTap: () { Navigator.pop(context); }),
          const Divider(color: MyColors.border_qcyber),
          _buildDrawerItem(icon: Icons.settings, text: "Configurações", onTap: () { Navigator.pop(context); }),
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

  Widget _buildKpiSection() {
    return FutureBuilder<KpiSummary>(
      future: _kpisFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text("Não foi possível carregar as métricas.");
        }
        final kpis = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildKpiCard('Alertas', kpis.totalAlerts24h.toString(), Icons.warning_amber, MyColors.error_qcyber)),
            const SizedBox(width: 12),
            // <<< MUDANÇA AQUI: Cor do ícone de Ameaças alterada >>>
            Expanded(child: _buildKpiCard('Ameaças', kpis.ameacasBloqueadas.toString(), Icons.shield, MyColors.primary_qcyber)),
            const SizedBox(width: 12),
            Expanded(child: _buildKpiCard('Acurácia', '${(kpis.avgAccuracy24h * 100).toStringAsFixed(1)}%', Icons.check_circle_outline, MyColors.success_qcyber)),
            const SizedBox(width: 12),
            Expanded(child: _buildKpiCard('Dispositivos', kpis.dispositivosProtegidos.toString(), Icons.computer, MyColors.primary_qcyber)),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 14)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: MyColors.textPrimary_qcyber, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContentSection() {
    return FutureBuilder<PaginatedAnalyses>(
      future: _analysesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data.isEmpty) {
          return const Center(child: Text('Nenhuma análise encontrada para este período.'));
        }
        final analyses = snapshot.data!.data;
        return Column(
          children: [
            _buildChartSection(context, analyses),
            const SizedBox(height: 24),
            _buildDataTableSection(context, analyses),
          ],
        );
      },
    );
  }

  Widget _buildChartSection(BuildContext context, List<Analise> analises) {
    final reversedAnalises = analises.reversed.toList();
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Performance do Modelo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: MyColors.border_qcyber, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text("${(value * 100).toInt()}%", style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: MyColors.border_qcyber)),
                  minY: 0,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < reversedAnalises.length; i++)
                          FlSpot(i.toDouble(), reversedAnalises[i].acuracia)
                      ],
                      isCurved: true,
                      color: MyColors.chart1_qcyber,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: MyColors.chart1_qcyber.withOpacity(0.2)),
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

  Widget _buildDataTableSection(BuildContext context, List<Analise> analises) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Histórico de Análises Recentes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber),
                dataTextStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Acurácia')),
                  DataColumn(label: Text('VP')),
                  DataColumn(label: Text('VN')),
                  DataColumn(label: Text('FP')),
                  DataColumn(label: Text('FN')),
                ],
                rows: analises.map((analise) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((states) => analise.isAlerta ? MyColors.error_qcyber.withOpacity(0.1) : null),
                  cells: [
                    DataCell(Text(analise.id.toString())),
                    DataCell(Text(DateFormat('dd/MM HH:mm').format(analise.dataAnalise))),
                    DataCell(Text("${(analise.acuracia * 100).toStringAsFixed(1)}%")),
                    DataCell(Text(analise.tp.toString())),
                    DataCell(Text(analise.tn.toString())),
                    DataCell(Text(analise.fp.toString())),
                    DataCell(Text(analise.fn.toString())),
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
