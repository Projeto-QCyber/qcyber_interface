///VERSAO COM O TOM CINZA

import 'package:flutter/material.dart';

class MyColors {

  // --- CORES FIXADAS POR VOCÊ ---
  static const Color primary_qcyber = Color(0xFF4A5568);    // Primária (Elementos) - Ardósia
  static const Color background_qcyber = Color(0xFF1A202C);  // Fundo - Quase Preto
  static const Color card_qcyber = Color(0xFF2D3748);      // Cards - Charcoal
  static const Color textPrimary_qcyber = Color(0xFFEDF2F7);   // Texto Principal - Branco

  // --- CORES AJUSTADAS PARA HARMONIZAR ---

  // Cor de Destaque (Mantida)
  static const Color accent_qcyber = Color(0xFF48BB78);  // Verde "Cyber" para destaque

  // Cores Neutras (UI Base)
  static const Color textSecondary_qcyber = Color(0xFFA0AEC0); // Texto secundário (Mantido)
  static const Color textOnPrimary_qcyber = Color(0xFFEDF2F7);   // Texto sobre o primário (Mantido)
  static const Color border_qcyber = Color(0xFF4A5568);      // AJUSTADO: Alinhado com a cor primária para coesão

  // Cores para Gráficos (Data Visualization)
  static const Color chart1_qcyber = accent_qcyber;     // O verde principal (Mantido)
  static const Color chart2_qcyber = Color(0xFF00B5D8);     // Ciano vibrante (Mantido)
  static const Color chart3_qcyber = Color(0xFFD69E2E); // Amarelo/Âmbar
  static const Color chart4_qcyber = Color(0xFF7F92B0);     // Azul Dessaturado (Mantido)

  // Cores Semânticas (Status e Feedback) - Mantidas
  static const Color success_qcyber = Color(0xFF48BB78);
  static const Color error_qcyber = Color(0xFFE53E3E);
  static const Color orange_qcyber = Color(0xFFDD6B20);
  static const Color warning_qcyber = Color(0xFFD69E2E);

  // Cores Semânticas de Risco - Mantidas
  // Nível Baixo
  static final Color riskLowBackground = Colors.green.withOpacity(0.1);
  static final Color riskLowText = Colors.green.shade200;

  // Nível Médio
  static final Color riskMediumBackground = Colors.yellow.withOpacity(0.1);
  static final Color riskMediumText = Colors.yellow.shade300;

  // Nível Alto
  static final Color riskHighBackground = Colors.orange.withOpacity(0.15);
  static final Color riskHighText = Colors.orange.shade300;

  // Nível Crítico
  static final Color riskCriticalBackground = Colors.red.withOpacity(0.15);
  static final Color riskCriticalText = Colors.red.shade300;

  // Nível Desconhecido (Fallback)
  // static const Color riskUnknownBackground = border_qcyber;
  static const Color riskUnknownBackground = border_qcyber;
  static const Color riskUnknownText = textSecondary_qcyber;
}