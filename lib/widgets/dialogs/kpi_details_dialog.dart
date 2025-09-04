import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';

class KpiDetailsDialog {
  /// Exibe um diálogo genérico para mostrar detalhes de um KPI.
  ///
  /// [context] O BuildContext da tela.
  /// [title] O título do modal.
  /// [icon] O ícone a ser exibido no topo.
  /// [iconColor] A cor do ícone.
  /// [children] A lista de widgets a ser exibida no corpo do modal.
  static void show(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: MyColors.card_qcyber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: MyColors.textPrimary_qcyber, fontSize: 22)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: children.isEmpty
                ? const Center(child: Text("Nenhum item para exibir.", style: TextStyle(color: MyColors.textSecondary_qcyber)))
                : ListView(
              shrinkWrap: true,
              children: children,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('FECHAR', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}