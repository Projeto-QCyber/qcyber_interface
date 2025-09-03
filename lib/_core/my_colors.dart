import 'package:flutter/material.dart';

class MyColors {
  static const MaterialColor red = MaterialColor(_redPrimaryValue, <int, Color>{
    50: Color(0xFFFAE3E5),
    100: Color(0xFFF4BABF),
    200: Color(0xFFEC8C94),
    300: Color(0xFFE45D69),
    400: Color(0xFFDF3B48),
    500: Color(_redPrimaryValue),
    600: Color(0xFFD51524),
    700: Color(0xFFCF111E),
    800: Color(0xFFCA0E18),
    900: Color(0xFFC0080F),
  });
  static const int _redPrimaryValue = 0xFFD91828;

  static const MaterialColor redAccent =
      MaterialColor(_redAccentValue, <int, Color>{
    100: Color(0xFFFFEBEB),
    200: Color(_redAccentValue),
    400: Color(0xFFFF8587),
    700: Color(0xFFFF6B6E),
  });
  static const int _redAccentValue = 0xFFFFB8B9;

  static const MaterialColor blue =
      MaterialColor(_bluePrimaryValue, <int, Color>{
    50: Color(0xFFE8EDF4),
    100: Color(0xFFC5D2E4),
    200: Color(0xFF9EB5D3),
    300: Color(0xFF7797C1),
    400: Color(0xFF5980B3),
    500: Color(_bluePrimaryValue),
    600: Color(0xFF36629E),
    700: Color(0xFF2E5795),
    800: Color(0xFF274D8B),
    900: Color(0xFF1A3C7B),
  });
  static const int _bluePrimaryValue = 0xFF3C6AA6;

  static const MaterialColor blueAccent =
      MaterialColor(_blueAccentValue, <int, Color>{
    100: Color(0xFFB4CCFF),
    200: Color(_blueAccentValue),
    400: Color(0xFF4E87FF),
    700: Color(0xFF3575FF),
  });
  static const int _blueAccentValue = 0xFF81A9FF;

  static const MaterialColor green =
      MaterialColor(_greenPrimaryValue, <int, Color>{
    50: Color(0xFFF5F7E6),
    100: Color(0xFFE7ECC1),
    200: Color(0xFFD7DF98),
    300: Color(0xFFC7D26E),
    400: Color(0xFFBBC94F),
    500: Color(_greenPrimaryValue),
    600: Color(0xFFA8B92B),
    700: Color(0xFF9FB124),
    800: Color(0xFF96A91E),
    900: Color(0xFF869B13),
  });
  static const int _greenPrimaryValue = 0xFFAFBF30;

  static const MaterialColor greenAccent =
      MaterialColor(_greenAccentValue, <int, Color>{
    100: Color(0xFFF7FFCE),
    200: Color(_greenAccentValue),
    400: Color(0xFFE5FF68),
    700: Color(0xFFE1FF4E),
  });
  static const int _greenAccentValue = 0xFFEEFF9B;

  static const MaterialColor greenlight =
      MaterialColor(_greenlightPrimaryValue, <int, Color>{
    50: Color(0xFFF9FAEF),
    100: Color(0xFFF0F4D6),
    200: Color(0xFFE6ECBB),
    300: Color(0xFFDCE4A0),
    400: Color(0xFFD5DF8B),
    500: Color(_greenlightPrimaryValue),
    600: Color(0xFFC8D56F),
    700: Color(0xFFC1CF64),
    800: Color(0xFFBACA5A),
    900: Color(0xFFAEC047),
  });
  static const int _greenlightPrimaryValue = 0xFFCDD977;

  static const MaterialColor greenlightAccent =
      MaterialColor(_greenlightAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_greenlightAccentValue),
    400: Color(0xFFF3FFB2),
    700: Color(0xFFEFFF98),
  });
  static const int _greenlightAccentValue = 0xFFFBFFE5;

  static const MaterialColor brown =
      MaterialColor(_brownPrimaryValue, <int, Color>{
    50: Color(0xFFF1EBE8),
    100: Color(0xFFDDCEC5),
    200: Color(0xFFC6AD9F),
    300: Color(0xFFAF8C78),
    400: Color(0xFF9D745B),
    500: Color(_brownPrimaryValue),
    600: Color(0xFF845338),
    700: Color(0xFF794930),
    800: Color(0xFF6F4028),
    900: Color(0xFF5C2F1B),
  });
  static const int _brownPrimaryValue = 0xFF8C5B3E;



  static const MaterialColor brownAccent =
      MaterialColor(_brownAccentValue, <int, Color>{
    100: Color(0xFFFFB69A),
    200: Color(_brownAccentValue),
    400: Color(0xFFFF6C34),
    700: Color(0xFFFF5A1A),
  });
  static const int _brownAccentValue = 0xFFFF9167;


  static const Color fundo_app1 = const Color.fromRGBO(255, 255, 255, 1.0);

  static const Color principal_app1 = const Color.fromRGBO(33, 34, 93, 1.0);

  static const Color destaque_app1 = const Color.fromRGBO(23, 50, 50, 1.0);


  // --- Cores Primárias (Branding) ---

  /// Cor Principal: Azul escuro, base da identidade visual.
  /// Usada para AppBars, botões principais e fundos de seções importantes.
  /// HEX: #21225D
  static const Color primary_qcyber = Color(0xFF21225D);

  /// Cor de Destaque Principal: Ciano vibrante.
  /// Usada para elementos interativos, links, e como cor principal em gráficos.
  /// HEX: #00E5FF
  static const Color accent_qcyber = Color(0xFF00E5FF);

  // --- Cores Neutras (UI Base) ---

  /// Fundo Principal: Cinza muito claro, para reduzir o cansaço visual.
  /// HEX: #F4F7FC
  static const Color background_qcyber = Color(0xFFF4F7FC);

  /// Fundo de Cards: Branco puro, para destacar os painéis de conteúdo.
  /// HEX: #FFFFFF
  static const Color card_qcyber = Color(0xFFFFFFFF);

  /// Texto Principal: Cinza escuro, para máxima legibilidade.
  /// HEX: #1A202C
  static const Color textPrimary_qcyber = Color(0xFF1A202C);

  /// Texto Secundário: Cinza médio, para rótulos e descrições.
  /// HEX: #718096
  static const Color textSecondary_qcyber = Color(0xFF718096);

  /// Texto sobre fundos escuros (como botões primários).
  static const Color textOnPrimary_qcyber = Colors.white;

  /// Bordas e Divisórias: Cinza claro.
  /// HEX: #E2E8F0
  static const Color border_qcyber = Color(0xFFE2E8F0);

  // --- Cores para Gráficos (Data Visualization) ---
  // Um conjunto de cores distintas que funcionam bem juntas.

  /// Cor 1 para Gráficos (a principal).
  static const Color chart1_qcyber = accent_qcyber; // Ciano
  /// Cor 2 para Gráficos.
  static const Color chart2_qcyber = Color(0xFF805AD5); // Roxo
  /// Cor 3 para Gráficos.
  static const Color chart3_qcyber = Color(0xFFED64A6); // Rosa
  /// Cor 4 para Gráficos.
  static const Color chart4_qcyber = Color(0xFF319795); // Verde-azulado

  // --- Cores Semânticas (Status e Feedback) ---

  /// Sucesso: Verde.
  /// Para mensagens de sucesso, dados positivos, etc.
  /// HEX: #38A169
  static const Color success_qcyber = Color(0xFF38A169);

  /// Erro/Alerta: Vermelho.
  /// Para mensagens de erro, dados críticos, etc.
  /// HEX: #E53E3E
  static const Color error_qcyber = Color(0xFFE53E3E);

  static const Color orange_qcyber = Color(0xFFFF8000);

  /// Aviso: Âmbar/Amarelo.
  /// Para avisos, dados que requerem atenção, etc.
  /// HEX: #D69E2E
  static const Color warning_qcyber = Color(0xFFD69E2E);

}
