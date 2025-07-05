class Analise {
  final int id;
  final DateTime dataAnalise;
  final double acuracia;
  final int tp, tn, fp, fn;
  final bool isAlerta;

  Analise({
    required this.id,
    required this.dataAnalise,
    required this.acuracia,
    required this.tp,
    required this.tn,
    required this.fp,
    required this.fn,
    required this.isAlerta,
  });

  // Factory constructor para criar uma instância de Analise a partir de um JSON
  factory Analise.fromJson(Map<String, dynamic> json) {
    return Analise(
      id: json['id'],
      // Converte a string de data da API para um objeto DateTime do Dart
      dataAnalise: DateTime.parse(json['data_analise']),
      // Garante que a acurácia seja tratada como um número decimal (double)
      acuracia: (json['acuracia'] as num).toDouble(),
      tp: json['tp'],
      tn: json['tn'],
      fp: json['fp'],
      fn: json['fn'],
      isAlerta: json['is_alerta'],
    );
  }
}