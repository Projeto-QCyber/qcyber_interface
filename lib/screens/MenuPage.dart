import 'dart:async'; // 1. Importa a biblioteca para usar o Timer
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
// Correção: Padronizando o caminho e o nome do arquivo para minúsculas.
import 'package:zeropoint/objetos/analise.dart';
import 'package:zeropoint/services/dashboard_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<List<Analise>> _analisesFuture;
  Timer? _timer; // 2. Variável para controlar o nosso timer

  @override
  void initState() {
    super.initState();
    _fetchData(); // 3. Faz a primeira busca de dados ao iniciar a tela
    // 4. Configura o timer para chamar a função _fetchData a cada 3 minutos
    _timer = Timer.periodic(const Duration(minutes: 3), (Timer t) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel(); // 5. É muito importante cancelar o timer ao sair da tela para evitar vazamentos de memória
    super.dispose();
  }

  // 6. Nova função para buscar os dados e atualizar o estado da tela
  void _fetchData() {
    if (mounted) { // Garante que o widget ainda está na tela antes de atualizar
      setState(() {
        print("Buscando novos dados... (${DateTime.now()})");
        _analisesFuture = _dashboardService.fetchAnalises();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Análises QCyber'),
        backgroundColor: MyColors.principal_app1,
        elevation: 0,
        actions: [
          // 7. Adiciona um botão de atualização manual para melhor experiência do usuário
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Dados',
            onPressed: _fetchData,
          ),
        ],
      ),
      backgroundColor: MyColors.fundo_app1,
      body: FutureBuilder<List<Analise>>(
        future: _analisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: MyColors.principal_app1));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}', style: TextStyle(color: MyColors.principal_app1)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma análise encontrada.', style: TextStyle(color: MyColors.principal_app1)));
          }

          final analises = snapshot.data!;
          final alertas = analises.where((a) => a.isAlerta).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAlertsSection(context, alertas),
                const SizedBox(height: 24),
                _buildChartSection(context, analises),
                const SizedBox(height: 24),
                _buildDataTableSection(context, analises),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, List<Analise> alertas) {
    if (alertas.isEmpty) {
      return Card(
        color: MyColors.principal_app1.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("✅ Tudo certo! Nenhum alerta recente.", style: TextStyle(color: MyColors.fundo_app1, fontWeight: FontWeight.bold)),
        ),
      );
    }
    return Card(
      color: Colors.red[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🚨 Alertas Recentes (${alertas.length})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...alertas.take(3).map((alerta) => Text(
              "• ID ${alerta.id}: Acurácia de ${(alerta.acuracia * 100).toStringAsFixed(1)}% em ${DateFormat('dd/MM HH:mm').format(alerta.dataAnalise)}",
              style: const TextStyle(color: Colors.white),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List<Analise> analises) {
    final reversedAnalises = analises.reversed.toList();

    return Card(
      color: MyColors.principal_app1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Evolução da Acurácia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.fundo_app1)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: MyColors.fundo_app1.withOpacity(0.2), strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text("${(value * 100).toInt()}%", style: TextStyle(color: MyColors.fundo_app1.withOpacity(0.7), fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: MyColors.fundo_app1.withOpacity(0.2))),
                  minY: 0,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < reversedAnalises.length; i++)
                          FlSpot(i.toDouble(), reversedAnalises[i].acuracia)
                      ],
                      isCurved: true,
                      color: Colors.cyanAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.cyanAccent.withOpacity(0.2)),
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
      color: MyColors.principal_app1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Histórico de Análises", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.fundo_app1)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: MyColors.fundo_app1),
                dataTextStyle: TextStyle(color: MyColors.fundo_app1.withOpacity(0.8)),
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
                  color: MaterialStateProperty.resolveWith<Color?>((states) => analise.isAlerta ? Colors.red.withOpacity(0.2) : null),
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
