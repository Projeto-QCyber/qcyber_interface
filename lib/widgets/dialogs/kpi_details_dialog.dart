import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';

class KpiDetailsDialog {
  /// Displays a generic dialog to show KPI details.
  ///
  /// [context] The BuildContext of the screen.
  /// [title] The title of the modal.
  /// [icon] The icon to be displayed at the top.
  /// [iconColor] The color of the icon.
  /// [children] The list of widgets to be displayed in the modal body.
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
                ? const Center(child: Text("No items to display.", style: TextStyle(color: MyColors.textSecondary_qcyber)))
                : ListView(
              shrinkWrap: true,
              children: children,
            ),
          ),
          actions: [
            TextButton(
              // Use the 'style' property to customize the button
              style: TextButton.styleFrom(

                // Button background color
                backgroundColor: MyColors.textOnPrimary_qcyber,
                // Text color (and click effect)
                foregroundColor: MyColors.primary_qcyber,

                // Optional: if you want rounded corners
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),

              // Now the Text no longer needs the style property
              child: const Text('CLOSE'),

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