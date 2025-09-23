// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// ATUALIZADO: Usando seus próprios arquivos de Config e Model
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart'; // Certifique-se que o caminho está correto

class AuthService {
  // ATUALIZADO: Usando a URL do seu config.dart
  final String _baseUrl = Config.apiUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/usuarios/"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'nome': nome, 'email': email, 'senha': password}),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'email': responseBody['email']};
      } else {
        return {'success': false, 'error': responseBody['detail'] ?? 'Erro desconhecido.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login/token"),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 202) { // 2FA é necessário
        return {'success': true, 'requires_2fa': true, 'temp_token': responseBody['temp_token']};
      } else if (response.statusCode == 200) { // Login direto
        await _tokenStorage.saveToken(responseBody['access_token']);
        return {'success': true, 'requires_2fa': false};
      } else if (response.statusCode == 403) { // E-mail não verificado
        return {'success': false, 'error': responseBody['detail'], 'requires_email_verification': true};
      } else { // Outros erros (ex: senha incorreta)
        return {'success': false, 'error': responseBody['detail'] ?? 'Credenciais inválidas.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/usuarios/verify-email"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {'success': false, 'error': responseBody['detail']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  Future<Map<String, dynamic>> verify2faLogin(String tempToken, String code) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login/token/2fa"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'temp_token': tempToken, 'code': code}),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _tokenStorage.saveToken(responseBody['access_token']);
        return {'success': true};
      } else {
        return {'success': false, 'error': responseBody['detail']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  // ATUALIZADO: O método de logout agora chama o Provider
  Future<void> logout(BuildContext context) async {
    // A chamada à API para invalidar o token no backend (se houver) iria aqui

    // ATUALIZADO: Usa o método de logout da sua classe UsuariosLogados
    final userProvider = Provider.of<UsuariosLogados>(context, listen: false);
    await userProvider.logout();
  }

  Future<bool> fetchAndSetUser(BuildContext context) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/usuarios/me"), // Chama a nova rota /me
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // Atualiza o provider com os dados reais do usuário
        Provider.of<UsuariosLogados>(context, listen: false).atualizarUsuarioLogado(
          id: userData['id'],
          nome: userData['nome'],
          isAdmin: userData['is_admin'] ?? false,
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/usuarios/request-password-reset"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      // A API sempre retorna 200 OK para evitar vazar informações
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {'success': true, 'message': responseBody['message']};
      } else {
        // Mesmo em outros casos, retornamos uma mensagem genérica
        return {'success': false, 'error': 'Ocorreu um erro. Tente novamente.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }


  Future<Map<String, dynamic>> performPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/usuarios/perform-password-reset"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'token': token,
          'nova_senha': newPassword,
        }),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        // A API pode retornar 400 para token inválido/expirado
        return {'success': false, 'error': responseBody['detail'] ?? 'Não foi possível redefinir a senha.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }
}