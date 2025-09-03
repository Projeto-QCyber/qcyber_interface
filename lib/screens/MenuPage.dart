import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';
import 'package:zeropoint/screens/ameacas_screen.dart';
import 'package:zeropoint/screens/dispositivos_screen.dart';
import 'package:zeropoint/services/dashboard_service.dart';

enum DateRangePreset { last24h, last7d, last30d, custom }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardSummary> _dashboardFuture;
  Timer? _timer;
  int _touchedIndex = -1;

  DateRangePreset _selectedPreset = DateRangePreset.last24h;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(minutes: 3), (Timer t) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetchData() {
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
                  if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
                  if (snapshot.hasError) { return Center(child: Text('Erro ao carregar dados: ${snapshot.error}', style: const TextStyle(color: MyColors.textPrimary_qcyber))); }
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
                            _buildKpiSection(dashboardData.kpis),
                            const SizedBox(height: 24),
                            // *** LAYOUT CORRIGIDO COM TODOS OS GRÁFICOS ***
                            _buildLineChartDetections(dashboardData.deteccoesPorHora),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildPieChartAtaques(dashboardData.ataquesPorTipo)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildBarChartRiscos(dashboardData.incidentesPorRisco)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildBarChartDispositivos(dashboardData.dispositivosAtacados),
                            const SizedBox(height: 24),
                            _buildDataTableSection(dashboardData.ultimasDeteccoes),
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

  // --- Widgets de Construção da UI ---

  // ... (_buildDateFilter, _buildFilterChip, _buildDrawer, _buildDrawerItem, _buildKpiSection, _buildKpiCard não mudaram) ...
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

  Widget _buildKpiSection(Kpis kpis) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Detecções', kpis.totalDeteccoes.toString(), Icons.warning_amber, MyColors.error_qcyber)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Ações Autom.', kpis.acoesExecutadas.toString(), Icons.shield, MyColors.primary_qcyber)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Incidentes', kpis.incidentesCriados.toString(), Icons.assignment_late, Colors.orangeAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Dispositivos', kpis.dispositivosAtivos.toString(), Icons.computer, MyColors.primary_qcyber)),
      ],
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

  // Renomeado para maior clareza
  Widget _buildPieChartAtaques(List<AtaquePorTipo> ataques) {
    final pieColors = [ MyColors.chart1_qcyber, MyColors.chart2_qcyber, MyColors.chart3_qcyber, Colors.orangeAccent, MyColors.primary_qcyber.withOpacity(0.7) ];

    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tipos de Ameaças", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            if (ataques.isEmpty)
              const Center(heightFactor: 5, child: Text('Nenhum dado.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) { _touchedIndex = -1; return; }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(ataques.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 70.0 : 60.0;
                      final ataque = ataques[i];
                      String displayTitle = ataque.nomeAtaque.length > 8 ? '${ataque.nomeAtaque.substring(0, 5)}..' : ataque.nomeAtaque;

                      return PieChartSectionData(
                        color: pieColors[i % pieColors.length],
                        value: ataque.total.toDouble(),
                        title: displayTitle.replaceAll('_', '\n'),
                        radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)]),
                        badgeWidget: isTouched ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.3))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ataque.nomeAtaque.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              SizedBox(width: 150, child: Text(ataque.descricao, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 3, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ) : null,
                        badgePositionPercentageOffset: isTouched ? 1.05 : 0.98,
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

  // **** FUNÇÕES ADICIONADAS PARA OS NOVOS GRÁFICOS ****

  Widget _buildLineChartDetections(List<DeteccoesPorHora> data) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Volume de Detecções", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            if (data.isEmpty)
              const Center(heightFactor: 5, child: Text('Nenhum dado de volume para exibir.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) return const Text('');
                        final is24h = (data.last.hora.difference(data.first.hora).inHours <= 24);
                        final format = is24h ? DateFormat('HH:mm') : DateFormat('dd/MM');
                        return Text(format.format(data[value.toInt()].hora.toLocal()), style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 10));
                      }, interval: (data.length / 4).ceilToDouble())),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: MyColors.border_qcyber)),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [ for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].total.toDouble()) ],
                        isCurved: true,
                        color: MyColors.chart1_qcyber,
                        barWidth: 3,
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

  Widget _buildBarChartDispositivos(List<DispositivosAtacados> data) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dispositivos Mais Atacados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 20),
            if (data.isEmpty)
              const Center(heightFactor: 5, child: Text('Nenhum dispositivo atacado no período.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              ...data.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(width: 150, child: Text(item.nomeDispositivo, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MyColors.textSecondary_qcyber))),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: item.total / (data.first.total > 0 ? data.first.total : 1),
                        backgroundColor: MyColors.border_qcyber,
                        valueColor: const AlwaysStoppedAnimation<Color>(MyColors.chart2_qcyber),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(width: 50, child: Text(' ${item.total}', style: const TextStyle(color: MyColors.textPrimary_qcyber, fontWeight: FontWeight.bold))),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  // Em screens/MenuPage.dart

  Widget _buildBarChartRiscos(List<IncidentesPorRisco> data) {
    final riskColors = {'Crítico': MyColors.error_qcyber, 'Alto': Colors.orangeAccent, 'Médio': MyColors.chart3_qcyber, 'Baixo': MyColors.primary_qcyber};

    // Se não houver dados, retorna o card vazio.
    if (data.isEmpty) {
      return Card(
        color: MyColors.card_qcyber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Incidentes por Risco", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
              const SizedBox(height: 20),
              const Center(heightFactor: 5, child: Text('Nenhum incidente.', style: TextStyle(color: MyColors.textSecondary_qcyber))),
            ],
          ),
        ),
      );
    }

    // --- LÓGICA ATUALIZADA PARA ESCALA DINÂMICA ---
    // 1. Encontra o maior valor Y (o número máximo de incidentes)
    final maxY = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);

    // 2. Calcula um intervalo inteligente para a escala, para ter no máximo 4 ou 5 rótulos
    double interval = (maxY / 4).ceilToDouble();
    if (interval < 1) interval = 1; // O intervalo mínimo deve ser 1

    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Incidentes por Risco", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY.toDouble(), // Define o valor máximo do eixo Y
                  titlesData: FlTitlesData(
                    // 3. ATUALIZAÇÃO DA ESCALA ESQUERDA (EIXO Y)
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28, // Aumenta um pouco o espaço reservado
                      interval: interval, // Usa o intervalo calculado
                      getTitlesWidget: (value, meta) {
                        // Garante que apenas números inteiros sejam mostrados
                        if (value == meta.max) return const SizedBox.shrink(); // Não mostra o último label
                        return Text(value.toInt().toString(), style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 10));
                      },
                    )),
                    // --- FIM DA ATUALIZAÇÃO ---
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      if (value.toInt() >= data.length) return const Text('');
                      return Text(data[value.toInt()].nivelRisco.substring(0,3), style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 10));
                    })),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) => BarChartGroupData(
                    x: i,
                    barRods: [BarChartRodData(toY: data[i].total.toDouble(), color: riskColors[data[i].nivelRisco] ?? Colors.grey, width: 16, borderRadius: BorderRadius.zero)],
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTableSection(List<UltimaDeteccao> deteccoes) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Histórico de Detecções Recentes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 8),
            if(deteccoes.isEmpty)
              const Center(heightFactor: 3, child: Text('Nenhuma detecção recente para exibir no período.', style: TextStyle(color: MyColors.textSecondary_qcyber)))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber),
                  dataTextStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
                  columns: const [
                    DataColumn(label: Text('Data/Hora')),
                    DataColumn(label: Text('Dispositivo')),
                    DataColumn(label: Text('Ameaça')),
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