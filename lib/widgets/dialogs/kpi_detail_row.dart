import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';

class KpiDetailRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const KpiDetailRow({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: iconColor ?? MyColors.textSecondary_qcyber, size: 24)
          : null,
      title: Text(title, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: MyColors.textSecondary_qcyber))
          : null,
      trailing: trailing,
      dense: true, // Reduz um pouco o espaçamento vertical para listas
    );
  }
}