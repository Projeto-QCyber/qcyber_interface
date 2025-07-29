import 'package:zeropoint/objetos/analise.dart';

/// Representa a resposta paginada da lista de análises.
class PaginatedAnalyses {
  final int totalItems;
  final int page;
  final int limit;
  final List<Analise> data;

  PaginatedAnalyses({
    required this.totalItems,
    required this.page,
    required this.limit,
    required this.data,
  });

  factory PaginatedAnalyses.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Analise> analysesList = list.map((i) => Analise.fromJson(i)).toList();

    return PaginatedAnalyses(
      totalItems: json['total_items'],
      page: json['page'],
      limit: json['limit'],
      data: analysesList,
    );
  }
}
