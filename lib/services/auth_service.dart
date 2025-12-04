// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para rotas públicas
import 'package:http_interceptor/http_interceptor.dart' as interceptor; // Para rotas protegidas
import 'package:provider/provider.dart';

import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/services/token_storage_service.dart';
import 'package:zeropoint/services/http_interceptor.dart';

class AuthService {
  final String _baseUrl = Config.apiUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Cliente HTTP "inteligente" para rotas protegidas
  // Nota: O RetryPolicy (no arquivo http_interceptor.dart) deve usar a lógica de refresh
  late final interceptor.InterceptedHttp _interceptedHttp;

  AuthService() {
    _interceptedHttp = interceptor.InterceptedHttp.build(
      interceptors: [AuthInterceptor()],
      retryPolicy: RetryPolicy(),
    );
  }

  // ===========================================================================
  // ROTAS PÚBLICAS (Login, Registro, Recuperação de Senha)
  // ===========================================================================

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

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

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

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 202) { // 2FA necessário
        return {
          'success': true,
          'requires_2fa': true,
          'temp_token': responseBody['temp_token']
        };
      } else if (response.statusCode == 200) { // Sucesso
        final accessToken = responseBody['access_token'];
        // Agora garantimos que pegamos o refresh token
        final refreshToken = responseBody['refresh_token'] ?? accessToken;

        await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken
        );

        return {'success': true, 'requires_2fa': false};
      } else if (response.statusCode == 403) { // Email não verificado
        return {
          'success': false,
          'error': responseBody['detail'],
          'requires_email_verification': true
        };
      } else {
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
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

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
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final accessToken = responseBody['access_token'];
        final refreshToken = responseBody['refresh_token'] ?? accessToken;

        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return {'success': true};
      } else {
        return {'success': false, 'error': responseBody['detail']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/usuarios/request-password-reset"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'message': responseBody['message']};
      } else {
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
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {'success': false, 'error': responseBody['detail'] ?? 'Falha ao redefinir senha.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Não foi possível conectar à API.'};
    }
  }

  // ===========================================================================
  // GERENCIAMENTO DE TOKENS (REFRESH E LOGOUT)
  // ===========================================================================

  /// Tenta renovar o Access Token usando o Refresh Token salvo.
  /// Retorna o novo Access Token se funcionar, ou null se falhar.
  Future<String?> performRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse("$_baseUrl/login/refresh"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final newAccessToken = data['access_token'];
        // Se a API retornar um novo refresh token (rotação), salvamos ele também
        final newRefreshToken = data['refresh_token'] ?? refreshToken;

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return newAccessToken;
      } else {
        // Refresh falhou (Expirado, Revogado ou Inválido)
        // Devemos forçar logout local para não ficar em loop
        await _tokenStorage.deleteTokens();
        return null;
      }
    } catch (e) {
      print("Erro ao tentar refresh token: $e");
      return null;
    }
  }

  /// Realiza o Logout completo com Blacklist
  Future<void> logout(BuildContext context) async {
    try {
      // 1. Recupera token para revogar (Blacklist)
      final refreshToken = await _tokenStorage.getRefreshToken();

      // 2. Avisa o backend se tivermos internet e token
      if (refreshToken != null) {
        try {
          await http.post(
            Uri.parse("$_baseUrl/login/logout"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': refreshToken}),
          );
        } catch (apiError) {
          print("Aviso: Falha ao contatar API de logout: $apiError");
          // Continua o logout local mesmo se a API falhar
        }
      }

      // 3. Apaga tokens do dispositivo (Segurança Local)
      await _tokenStorage.deleteTokens();

      // 4. Limpa o estado da memória (Provider)
      if (context.mounted) {
        Provider.of<UsuariosLogados>(context, listen: false).limparUsuario();
      }

    } catch (e) {
      print("Erro crítico no logout: $e");
      // Fallback de segurança
      await _tokenStorage.deleteTokens();
      if (context.mounted) {
        Provider.of<UsuariosLogados>(context, listen: false).limparUsuario();
      }
    }
  }

  // ===========================================================================
  // ROTAS PROTEGIDAS
  // ===========================================================================

  Future<bool> fetchAndSetUser(BuildContext context) async {
    try {
      final response = await _interceptedHttp.get(
        Uri.parse("$_baseUrl/usuarios/me"),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(utf8.decode(response.bodyBytes));

        Provider.of<UsuariosLogados>(context, listen: false).atualizarUsuarioLogado(
          id: userData['id'],
          nome: userData['nome'],
          email: userData['email'] ?? '',
          isAdmin: userData['is_admin'] ?? false,
          emailVerificado: true,
          doisFatoresAtivo: userData['dois_fatores_ativo'] ?? false,
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      return false;
    }
  }
}