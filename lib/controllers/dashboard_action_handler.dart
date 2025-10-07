import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/enums/nivel_risco_enum.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/dashboard_service.dart';
import 'package:zeropoint/widgets/dialogs/connection_error_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_details_dialog.dart';
import 'package:zeropoint/widgets/dialogs/kpi_detail_row.dart';

/// A dedicated class to handle user interactions on the dashboard.
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
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> showDeteccoesDetails({
    required int kpiCount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kpiCount == 0) {
      KpiDetailsDialog.show(context, title: "Latest Detections", icon: Icons.warning_amber, iconColor: MyColors.error_qcyber, children: []);
      return;
    }

    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchDeteccoesDetails(startDate: startDate, endDate: endDate);
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Latest Detections",
        icon: Icons.warning_amber,
        iconColor: MyColors.error_qcyber,
        children: details.map((d) => KpiDetailRow(
          icon: Icons.shield_moon_outlined,
          iconColor: MyColors.error_qcyber,
          title: d.tipoAtaque,
          subtitle: d.nomeDispositivo,
          trailing: Text(
            DateFormat('dd/MM HH:mm').format(d.dataDeteccao.toLocal()),
            style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 12),
          ),
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: () => showDeteccoesDetails(kpiCount: kpiCount, startDate: startDate, endDate: endDate));
    }
  }

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
          // 1. Converts the string from the API to our safe Enum
          final nivelRisco = NivelRisco.fromString(i.nivelRisco);

          // 2. Uses the Enum to get the colors and build the widget
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
                  color: nivelRisco.backgroundColor, // Color from the Enum
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  nivelRisco.displayName,
                  style: TextStyle(
                    color: nivelRisco.textColor, // Color from the Enum
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



  Future<void> showDispositivosDetails({required int kpiCount}) async {
    if (kpiCount == 0) {
      KpiDetailsDialog.show(context, title: "Active Devices", icon: Icons.computer, iconColor: MyColors.textOnPrimary_qcyber, children: []);
      return;
    }
    _showLoadingIndicator();
    try {
      final details = await dashboardService.fetchDispositivosDetails();
      _hideLoadingIndicator();
      KpiDetailsDialog.show(
        context,
        title: "Active Devices",
        icon: Icons.computer,
        iconColor: MyColors.textOnPrimary_qcyber,
        children: details.map((d) => KpiDetailRow(
          icon: Icons.circle,
          iconColor: Colors.green,
          title: d.nome,
          subtitle: d.host,
        )).toList(),
      );
    } catch (e) {
      _hideLoadingIndicator();
      ConnectionErrorDialog.show(context, onTryAgain: () => showDispositivosDetails(kpiCount: kpiCount));
    }
  }


}