import 'package:flutter/material.dart';

class MyColors {

  // --- Cores Primárias (Branding) ---
  static const Color primary_qcyber = Color(0xFF21225D);
  static const Color accent_qcyber = Color(0xFF00E5FF);

  // --- Cores Neutras (UI Base) ---
  static const Color background_qcyber = Color(0xFFF4F7FC);
  static const Color card_qcyber = Color(0xFFFFFFFF);
  static const Color textPrimary_qcyber = Color(0xFF1A202C);
  static const Color textSecondary_qcyber = Color(0xFF718096);
  static const Color textOnPrimary_qcyber = Colors.white;
  static const Color border_qcyber = Color(0xFFE2E8F0);

  // --- Cores para Gráficos (Data Visualization) ---
  static const Color chart1_qcyber = accent_qcyber;
  static const Color chart2_qcyber = Color(0xFF805AD5);
  static const Color chart3_qcyber = Color(0xFFED64A6);
  static const Color chart4_qcyber = Color(0xFF319795);

  // --- Cores Semânticas (Status e Feedback) ---
  static const Color success_qcyber = Color(0xFF38A169);
  static const Color error_qcyber = Color(0xFFE53E3E);
  static const Color orange_qcyber = Color(0xFFFF8000);
  static const Color warning_qcyber = Color(0xFFD69E2E);

  // NOVO: --- Cores Semânticas de Risco ---
  // Essas cores são usadas pelo Enum NivelRisco para manter a consistência.

  // Nível Baixo
  static final Color riskLowBackground = Colors.green.shade100;
  static final Color riskLowText = Colors.green.shade800;

  // Nível Médio
  static final Color riskMediumBackground = Colors.orange.shade100;
  static final Color riskMediumText = Colors.orange.shade800;

  // Nível Alto
  static final Color riskHighBackground = Colors.red.shade100;
  static final Color riskHighText = Colors.red.shade800;

  // Nível Crítico
  static final Color riskCriticalBackground = Colors.purple.shade100;
  static final Color riskCriticalText = Colors.purple.shade800;

  // Nível Desconhecido (Fallback)
  static const Color riskUnknownBackground = border_qcyber;
  static const Color riskUnknownText = textSecondary_qcyber;


}
