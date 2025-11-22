import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  // Configuração para evitar problemas conhecidos no Android/iOS
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token'; // Preparando para o futuro, mesmo se não usar agora

  /// Salva o token (e refresh token se houver)
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Recupera o token de acesso
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Recupera o refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Limpa tudo (Logout)
  Future<void> deleteTokens() async {
    await _storage.deleteAll();
  }

  /// Verifica se existe sessão (útil para o Splash/Router)
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Mantendo compatibilidade com seu código antigo que chamava "saveToken"
  Future<void> saveToken(String token) async {
    await saveTokens(accessToken: token);
  }

  // Mantendo compatibilidade com seu código antigo que chamava "getToken"
  Future<String?> getToken() => getAccessToken();
}