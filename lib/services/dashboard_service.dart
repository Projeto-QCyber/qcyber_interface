import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class DashboardService {
  Future<DashboardSummary> fetchDashboardSummary({DateTime? startDate, DateTime? endDate}) async {
    // Constrói a URI com os parâmetros de data, se existirem
    final Map<String, String> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }

    final uri = Uri.parse('${Config.apiUrl}/dashboard/summary').replace(queryParameters: queryParameters);

    // IMPORTANTE: Adicione o token de autenticação aqui!
    // TODO: Obter o token JWT salvo (ex: SharedPreferences) e adicioná-lo ao header
    final String? token = "SEU_TOKEN_JWT_AQUI"; // Substitua pela lógica real de obtenção do token

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Usa a função gerada para fazer o parse do JSON de forma segura
      return dashboardSummaryFromJson(response.body);
    } else {
      // Lança uma exceção se a chamada falhar
      throw Exception('Falha ao carregar os dados do dashboard. Status: ${response.statusCode}');
    }
  }
}