// lib/controllers/dashboard_action_handler.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/enums/nivel_risco_enum.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/dashboard_service.dart';
import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_details_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_detail_row.dart';
import 'package:zeropoint/screens/generic_history_screen.dart'; // Para o Enum HistoryFilterType

/// Classe dedicada para manipular as ações do Dashboard (Navegação e Dialogs)
class DashboardActionHandler {
  final BuildContext context;
  final DashboardService dashboardService;

  DashboardActionHandler({
    required this.context,
    required this.dashboardService,
  });

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingIndicator() {
    // ATUALIZADO: Uso do context.pop() (GoRouter)
    if (context.canPop()) {
      context.pop();
    }
  }

  // ===========================================================================
  // 1. NAVEGAÇÃO PARA TELAS COMPLETAS (Novas Rotas)
  // ===========================================================================

  Future<void> showDeteccoesDetails({
    required int kpiCount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Como criamos a tela 'AmeacasScreen', vamos navegar direto para ela
    // em vez de abrir um Dialog. A tela já busca os dados sozinha.
    context.push('/threats');

    // OBS: Se quisesse usar o Histórico Genérico com filtro, seria:
    // context.push('/history', extra: {'filterType': HistoryFilterType.threat});
  }

  Future<void> showDispositivosDetails({required int kpiCount}) async {
    // Navega direto para a tela de Gestão de Dispositivos
    context.push('/devices');
  }

  // ===========================================================================
  // 2. DIALOGS (Para itens que ainda não têm tela própria)
  // ===========================================================================

  Future<void> showAcoesDetails({
    required int kpiCount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kpiCount == 0) {
      KpiDetailsDialog.show(context, title: "Automated Actions", icon: Icons.shield, iconColor: MyColors.textOnPrimary_qcyber, children: []);
      return;
    }

    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchAcoesDetails(startDate: startDate, endDate: endDate);
      _hideLoadingIndicator();

      KpiDetailsDialog.show(
        context,
        title: "Recent Automated Actions",
        icon: Icons.shield,
        iconColor: MyColors.textOnPrimary_qcyber,
        children: details.map((acao) => KpiDetailRow(
          icon: Icons.check_circle,
          iconColor: MyColors.textOnPrimary_qcyber,
          title: acao.nomeAcao,
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: () => showAcoesDetails(kpiCount: kpiCount, startDate: startDate, endDate: endDate));
    }
  }

  Future<void> showIncidentesDetails({
    required int kpiCount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kpiCount == 0) {
      KpiDetailsDialog.show(context, title: "Recent Incidents", icon: Icons.assignment_late, iconColor: MyColors.orange_qcyber, children: []);
      return;
    }

    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchIncidentesDetails(startDate: startDate, endDate: endDate);
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Recent Incidents",
        icon: Icons.assignment_late,
        iconColor: MyColors.orange_qcyber,
        children: details.map((i) {
          final nivelRisco = NivelRisco.fromString(i.nivelRisco);

          return KpiDetailRow(
            icon: Icons.flag_outlined,
            iconColor: nivelRisco.textColor,
            title: i.titulo,
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: nivelRisco.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  nivelRisco.displayName,
                  style: TextStyle(
                    color: nivelRisco.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: () => showIncidentesDetails(kpiCount: kpiCount, startDate: startDate, endDate: endDate));
    }
  }
}