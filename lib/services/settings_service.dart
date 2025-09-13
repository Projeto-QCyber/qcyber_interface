// lib/services/settings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart';

class SettingsService {
  final String _baseUrl = "${Config.apiUrl}/admin";
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, String>> getSettings() async {
    final token = await _tokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/settings"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // A API retorna um JSON com chaves e valores, que o Dart interpreta como Map<String, dynamic>
      // Fazemos o cast para Map<String, String>
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception('Falha ao carregar configurações.');
    }
  }

  Future<bool> updateSettings(Map<String, String> settings) async {
    final token = await _tokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$_baseUrl/settings"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(settings),
    );
    return response.statusCode == 204;
  }
}