// lib/services/token_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gerencia o armazenamento seguro dos tokens de acesso e de atualização.
class TokenStorageService {
  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Salva ambos os tokens no armazenamento seguro.
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Recupera o token de acesso.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Recupera o token de atualização (refresh token).
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Deleta ambos os tokens do armazenamento.
  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getRefreshToken();
    return token != null;
  }
}