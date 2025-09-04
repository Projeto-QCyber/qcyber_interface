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

  Future<List<UltimaDeteccao>> fetchDeteccoesDetails({DateTime? startDate, DateTime? endDate}) async {
    final Map<String, String> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }

    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/deteccoes').replace(queryParameters: queryParameters);

    // TODO: Obter o token JWT salvo
    final String? token = "SEU_TOKEN_JWT_AQUI";

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Decodifica a lista diretamente
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => UltimaDeteccao.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes das detecções.');
    }
  }

  Future<List<AcaoDetail>> fetchAcoesDetails() async {
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/acoes');
    final String? token = "SEU_TOKEN_JWT_AQUI"; // TODO: Substituir
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => AcaoDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes das ações.');
    }
  }

  Future<List<IncidenteDetail>> fetchIncidentesDetails() async {
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/incidentes');
    final String? token = "SEU_TOKEN_JWT_AQUI"; // TODO: Substituir
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => IncidenteDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes dos incidentes.');
    }
  }

  Future<List<DispositivoDetail>> fetchDispositivosDetails() async {
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/dispositivos');
    final String? token = "SEU_TOKEN_JWT_AQUI"; // TODO: Substituir
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => DispositivoDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes dos dispositivos.');
    }
  }
}