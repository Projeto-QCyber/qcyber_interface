// lib/services/http_interceptor.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// A importação agora tem o "apelido" (alias) 'interceptor'
import 'package:http_interceptor/http_interceptor.dart' as interceptor;

import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/services/token_storage_service.dart';


// A classe agora extende a versão com alias: 'interceptor.InterceptorContract'
class AuthInterceptor extends interceptor.InterceptorContract {
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Os tipos aqui também usam o alias para clareza
  @override
  Future<interceptor.BaseRequest> interceptRequest({required interceptor.BaseRequest request}) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    } catch (e) {
      print(e);
    }
    return request;
  }

  @override
  Future<interceptor.BaseResponse> interceptResponse({required interceptor.BaseResponse response}) async {
    return response;
  }
}


// A classe agora extende a versão com alias: 'interceptor.RetryPolicy'
class RetryPolicy extends interceptor.RetryPolicy {
  final String _baseUrl = "${Config.apiUrl}/api";
  final TokenStorageService _tokenStorage = TokenStorageService();

  @override
  int get maxRetryAttempts => 2;

  // O tipo do parâmetro 'response' também usa o alias
  @override
  Future<bool> shouldAttemptRetryOnResponse(interceptor.BaseResponse response) async {
    if (response.statusCode == 401) {
      print("Token de acesso expirado. Tentando renovar...");

      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        print("Nenhum refresh token encontrado. Desistindo.");
        await _tokenStorage.deleteTokens();
        return false;
      }

      try {
        final refreshResponse = await http.post(
          Uri.parse("$_baseUrl/refresh-token"),
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (refreshResponse.statusCode == 200) {
          final newTokens = jsonDecode(refreshResponse.body);
          await _tokenStorage.saveTokens(
            accessToken: newTokens['access_token'],
            refreshToken: refreshToken,
          );
          print("Token renovado com sucesso. Tentando a requisição novamente.");
          return true;
        } else {
          print("Falha ao renovar o token (o refresh token pode estar inválido).");
          await _tokenStorage.deleteTokens();
          return false;
        }
      } catch (e) {
        print("Erro durante a tentativa de renovar token: $e");
        return false;
      }
    }
    return false;
  }
}