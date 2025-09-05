import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';
import 'package:zeropoint/services/dashboard_service.dart';
import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_details_dialog.dart';
import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_details_dialog.dart';

/// Uma classe dedicada a lidar com as interações do usuário na dashboard.
class DashboardActionHandler {
  final BuildContext context;
  final DashboardService dashboardService;

  DashboardActionHandler({
    required this.context,
    required this.dashboardService,
  });

  // Função genérica para mostrar o loading e fechar em caso de erro
  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingIndicator() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Lógica para o KPI de Detecções
  Future<void> showDeteccoesDetails() async {
    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchDeteccoesDetails();
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Últimas Detecções",
        icon: Icons.warning_amber,
        iconColor: MyColors.error_qcyber,
        children: details.map((d) => ListTile(
          title: Text(d.tipoAtaque, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
          subtitle: Text(d.nomeDispositivo, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
          trailing: Text(DateFormat('dd/MM HH:mm').format(d.dataDeteccao.toLocal()), style: const TextStyle(color: MyColors.textSecondary_qcyber)),
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: showDeteccoesDetails);
    }
  }

  // Lógica para o KPI de Ações Automáticas
  Future<void>  showAcoesDetails() async {
    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchAcoesDetails();
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Ações Automáticas Recentes",
        icon: Icons.shield,
        iconColor: MyColors.primary_qcyber,
        children: details.map((acao) => ListTile(
          leading: const Icon(Icons.check_circle, color: MyColors.primary_qcyber),
          title: Text(acao.nomeAcao, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
          // subtitle: Text(acao.nomeAcao, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: showAcoesDetails);
    }
  }

  // Lógica para o KPI de Incidentes
  Future<void>  showIncidentesDetails() async {
    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchIncidentesDetails();
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Incidentes Recentes",
        icon: Icons.assignment_late,
        iconColor: Colors.orangeAccent,
        children: details.map((i) => ListTile(
          title: Text(i.titulo, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
           subtitle: Text("teste", style: const TextStyle(color: MyColors.textSecondary_qcyber)),
          // **** ATUALIZADO: Usando Container para um estilo de chip fixo ****
          trailing: Container(
            width: 80, // Largura fixa para padronizar (ajuste conforme necessário)
            alignment: Alignment.center, // Centraliza o texto dentro do container
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              // Cor de fundo com base no nível de risco
              color: _getRiscoBackgroundColor(i.nivelRisco),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              i.nivelRisco,
              style: TextStyle(
                // Cor do texto com base no nível de risco
                color: _getRiscoTextColor(i.nivelRisco),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          // Fim da atualização
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: showIncidentesDetails);
    }
  }

  // **** NOVOS MÉTODOS AUXILIARES PARA CORES DO RISCO ****
  Color _getRiscoBackgroundColor(String nivelRisco) {
    switch (nivelRisco.toLowerCase()) {
      case 'baixo': return Colors.green.shade100;
      case 'medio': return Colors.orange.shade100;
      case 'alto': return Colors.red.shade100;
      case 'critico': return Colors.purple.shade100; // Ou outra cor para crítico
      default: return MyColors.border_qcyber; // Cor padrão
    }
  }

  Color _getRiscoTextColor(String nivelRisco) {
    switch (nivelRisco.toLowerCase()) {
      case 'baixo': return Colors.green.shade800;
      case 'medio': return Colors.orange.shade800;
      case 'alto': return Colors.red.shade800;
      case 'critico': return Colors.purple.shade800;
      default: return MyColors.textSecondary_qcyber;
    }
  }

  // Lógica para o KPI de Dispositivos
  Future<void>  showDispositivosDetails() async {
    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchDispositivosDetails();
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Dispositivos Ativos",
        icon: Icons.computer,
        iconColor: MyColors.primary_qcyber,
        children: details.map((d) => ListTile(
          leading: const Icon(Icons.circle, color: Colors.green, size: 12),
          title: Text(d.nome, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
          subtitle: Text(d.host, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: showDispositivosDetails);
    }
  }
}