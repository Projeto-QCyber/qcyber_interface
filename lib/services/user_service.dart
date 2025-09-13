// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/user_summary.dart'; // Corrija o caminho se necessário
import 'package:zeropoint/_core/services/token_storage_service.dart';

class UserService {
  final String _baseUrl = "${Config.apiUrl}/admin";
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<List<UserSummary>> getUsers({String searchTerm = ''}) async {
    final token = await _tokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/users?search=$searchTerm"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => UserSummary.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar usuários.');
    }
  }

  Future<bool> updateUserPermissions({
    required int userId,
    required bool isAdmin,
    required bool hasSystemAccess,
  }) async {
    final token = await _tokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$_baseUrl/users/$userId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'is_admin': isAdmin,
        'tem_permissao_sistema': hasSystemAccess,
      }),
    );
    return response.statusCode == 204;
  }


  Future<bool> resetPassword(int userId) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/users/$userId/reset-password"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      // A API retorna 200 OK em caso de sucesso
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao resetar senha: $e');
      return false;
    }
  }
}