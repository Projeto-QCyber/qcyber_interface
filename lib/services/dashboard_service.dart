import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:zeropoint/objetos/kpi_summary.dart';
import 'package:zeropoint/objetos/paginated_analyses.dart';

class DashboardService {
  final String _baseUrl = "http://localhost:5001/api";

  /// Busca os KPIs (Métricas Chave) da API, com filtro de data opcional.
  Future<KpiSummary> fetchKpis({DateTime? startDate, DateTime? endDate}) async {
    try {
      // Constrói a URL com os parâmetros de data, se existirem
      final uri = Uri.parse("$_baseUrl/dashboard-kpis").replace(
        queryParameters: _buildDateQueryParams(startDate, endDate),
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return KpiSummary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar KPIs da API');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar KPIs: $e');
    }
  }

  /// Busca uma lista paginada de análises da API, com suporte a filtros.
  Future<PaginatedAnalyses> fetchAnalises({
    int page = 1,
    int limit = 10,
    String filter = 'all',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Constrói a URL com todos os parâmetros
      final queryParams = _buildDateQueryParams(startDate, endDate);
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      queryParams['filter'] = filter;

      final uri = Uri.parse("$_baseUrl/analises").replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return PaginatedAnalyses.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar a lista de análises');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar análises: $e');
    }
  }

  /// Função auxiliar para criar os parâmetros de data no formato YYYY-MM-DD.
  Map<String, String> _buildDateQueryParams(DateTime? startDate, DateTime? endDate) {
    final Map<String, String> params = {};
    final formatter = DateFormat('yyyy-MM-dd');
    if (startDate != null) {
      params['start_date'] = formatter.format(startDate);
    }
    if (endDate != null) {
      params['end_date'] = formatter.format(endDate);
    }
    return params;
  }
}
