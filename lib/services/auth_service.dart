import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/auth_screen.dart'; // 1. IMPORTE O NOVO SERVIÇO

class AuthService {
  // 2. CRIE UMA INSTÂNCIA DO SERVIÇO
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${Config.apiUrl}/login/token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];

        // print('Login bem-sucedido. Token recebido: $token');

        // 3. SUBSTITUA O 'TODO' PELA CHAMADA REAL PARA SALVAR O TOKEN
        await _tokenStorage.saveToken(token);

        return {'success': true, 'token': token};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Erro desconhecido ao tentar fazer login.';
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return {'success': false, 'error': 'Não foi possível conectar ao servidor.'};
    }
  }

  // O método de registro continua igual...
  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${Config.apiUrl}/usuarios/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': password,
        }),
      );
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Conta criada com sucesso! Por favor, faça o login.'
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Erro desconhecido ao tentar se registrar.';
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('Erro de conexão no registro: $e');
      return {'success': false, 'error': 'Não foi possível conectar ao servidor.'};
    }
  }

  Future<void> logout(BuildContext context) async {

    final usuariosLogadosProvider = Provider.of<UsuariosLogados>(context, listen: false);
    await usuariosLogadosProvider.logout();

    // 1. Limpar o token do armazenamento seguro
    await _tokenStorage.deleteToken();

    // 2. (Opcional) Chamar a API para invalidar o token no backend
    // final response = await http.post(Uri.parse('${Config.apiUrl}/logout'), headers: ...);
    // if (response.statusCode == 200) { ... }

    // 3. Navegar para a tela de login e remover todas as telas anteriores
    // Usamos um serviço de navegação para fazer isso sem um BuildContext
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false,
    );
  }
}