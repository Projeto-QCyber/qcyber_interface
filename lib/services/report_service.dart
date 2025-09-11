// lib/services/report_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart'; // Ajuste o import
import 'package:zeropoint/_core/services/token_storage_service.dart'; // Ajuste o import

class ReportService {
  final String _baseUrl = "${Config.apiUrl}/report";
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Note que para download de arquivos, o Content-Type não é json.
  // A função auxiliar é um pouco diferente.
  Future<Map<String, String>> _getAuthHeaders() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Baixa o relatório em PDF de um dispositivo específico.
  /// Retorna os bytes do arquivo.
  Future<Uint8List> downloadDeviceReport(int deviceId) async {
    final uri = Uri.parse('$_baseUrl/by-device/$deviceId');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Tenta decodificar a mensagem de erro do backend se houver
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Falha ao baixar o relatório: ${error['detail']}');
      } catch (_) {
        throw Exception('Falha ao baixar o relatório. Status: ${response.statusCode}');
      }
    }
  }

  /// Baixa o relatório em PDF de um tipo de ameaça específico.
  Future<Uint8List> downloadThreatReport(int threatTypeId) async {
    final uri = Uri.parse('$_baseUrl/by-threat/$threatTypeId');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Falha ao baixar o relatório: ${error['detail']}');
      } catch (_) {
        throw Exception('Falha ao baixar o relatório. Status: ${response.statusCode}');
      }
    }
  }

  /// Baixa o relatório em PDF detalhado de uma única detecção.
  Future<Uint8List> downloadDetectionReport(int detectionId) async {
    final uri = Uri.parse('$_baseUrl/by-detection/$detectionId');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Falha ao baixar o relatório: ${error['detail']}');
      } catch (_) {
        throw Exception('Falha ao baixar o relatório. Status: ${response.statusCode}');
      }
    }
  }
}