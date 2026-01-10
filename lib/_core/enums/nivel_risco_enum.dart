import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';

/// Enum para representar os níveis de risco de forma segura e centralizada.
enum NivelRisco {
  baixo,
  medio,
  alto,
  critico,
  desconhecido; // Um valor padrão para casos inesperados

  /// Construtor de fábrica para criar um NivelRisco a partir de uma String da API.
  static NivelRisco fromString(String risco) {
    switch (risco.toLowerCase()) {
      case 'low':
        return NivelRisco.baixo;
      case 'medium':
        return NivelRisco.medio;
      case 'high':
        return NivelRisco.alto;
      case 'critical':
        return NivelRisco.critico;
      default:
      // Se a API retornar um valor desconhecido, temos um fallback seguro.
        return NivelRisco.desconhecido;
    }
  }

  /// Getter que retorna a cor de fundo associada a cada nível de risco.
  Color get backgroundColor {
    switch (this) {
      case NivelRisco.baixo:
        return MyColors.riskLowBackground;
      case NivelRisco.medio:
        return MyColors.riskMediumBackground;
      case NivelRisco.alto:
        return MyColors.riskHighBackground;
      case NivelRisco.critico:
        return MyColors.riskCriticalBackground;
      case NivelRisco.desconhecido:
        return MyColors.riskUnknownBackground;
    }
  }

  /// Getter que retorna a cor do texto associada a cada nível de risco.
  Color get textColor {
    switch (this) {
      case NivelRisco.baixo:
        return MyColors.riskLowText;
      case NivelRisco.medio:
        return MyColors.riskMediumText;
      case NivelRisco.alto:
        return MyColors.riskHighText;
      case NivelRisco.critico:
        return MyColors.riskCriticalText;
      case NivelRisco.desconhecido:
        return MyColors.riskUnknownText;
    }
  }

  String get displayName {
    switch (this) {
      case NivelRisco.baixo:
        return 'Low';
      case NivelRisco.medio:
        return 'Medium';
      case NivelRisco.alto:
        return 'High';
      case NivelRisco.critico:
        return 'Critical';
      case NivelRisco.desconhecido:
        return 'Unk.'; // Uma abreviação boa para o gráfico (Unknown)
    }
  }

}