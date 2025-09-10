import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart';
import 'package:zeropoint/objetos/dashboard/acao_detail.dart';
import 'package:zeropoint/objetos/dashboard/dispositivo_detail.dart';
import 'package:zeropoint/objetos/dashboard/incidente_detail.dart';
import 'package:zeropoint/objetos/dashboard/ultima_deteccao.dart';
import 'package:zeropoint/objetos/dashboard_summary.dart';

class DashboardService {
  // 2. CRIE UMA INSTÂNCIA DO SERVIÇO
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Função auxiliar para obter os headers com autenticação
  Future<Map<String, String>> _getAuthHeaders() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null) {
      // Você pode lançar um erro mais específico se preferir
      throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  Future<DashboardSummary> fetchDashboardSummary({DateTime? startDate, DateTime? endDate}) async {
    final Map<String, String> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }
    final uri = Uri.parse('${Config.apiUrl}/dashboard/summary').replace(queryParameters: queryParameters);

    // 3. OBTENHA OS HEADERS DE FORMA DINÂMICA
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return dashboardSummaryFromJson(response.body);
    } else {
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

    // 4. REUTILIZE A FUNÇÃO DE HEADERS
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => UltimaDeteccao.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes das detecções.');
    }
  }

  // 5. APLIQUE O MESMO PADRÃO PARA OS OUTROS MÉTODOS
  Future<List<AcaoDetail>> fetchAcoesDetails({DateTime? startDate, DateTime? endDate}) async {
    final Map<String, String> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/acoes').replace(queryParameters: queryParameters);

    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => AcaoDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes das ações.');
    }
  }

  Future<List<IncidenteDetail>> fetchIncidentesDetails({DateTime? startDate, DateTime? endDate}) async {
    final Map<String, String> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/incidentes').replace(queryParameters: queryParameters);

    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => IncidenteDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes dos incidentes.');
    }
  }

  Future<List<DispositivoDetail>> fetchDispositivosDetails() async {
    final uri = Uri.parse('${Config.apiUrl}/dashboard/details/dispositivos');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => DispositivoDetail.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar detalhes dos dispositivos.');
    }
  }
}