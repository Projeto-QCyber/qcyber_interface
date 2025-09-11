// lib/services/history_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart'; // Ajuste o import
import 'package:zeropoint/_core/services/token_storage_service.dart';
import 'package:zeropoint/objetos/detection_history_item.dart';
import 'package:zeropoint/objetos/filter_item.dart';
import 'package:zeropoint/objetos/incident_detail.dart'; // Ajuste o import


class HistoryService {
  final String _baseUrl = "${Config.apiUrl}/history";
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Busca as opções para os filtros (lista de dispositivos ou tipos de ameaça).
  Future<List<FilterItem>> getFilterOptions(String filterType) async {
    final uri = Uri.parse('$_baseUrl/filter/$filterType');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => FilterItem.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar opções do filtro. Status: ${response.statusCode}');
    }
  }

  /// Busca a lista de histórico com base no tipo e no ID selecionado.
  Future<List<DetectionHistoryItem>> getHistory(String historyType, int id) async {
    final uri = Uri.parse('$_baseUrl/$historyType/$id');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => DetectionHistoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar histórico. Status: ${response.statusCode}');
    }
  }

  /// Busca os detalhes completos de um incidente a partir do ID da detecção.
  Future<IncidentDetail> getIncidentDetail(int detectionId) async {
    final uri = Uri.parse('$_baseUrl/incident-detail/$detectionId');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return IncidentDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao carregar detalhes do incidente. Status: ${response.statusCode}');
    }
  }

}