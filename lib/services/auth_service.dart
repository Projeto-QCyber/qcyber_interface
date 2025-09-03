import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart'; // Mantido do seu projeto original

class AuthService {
  // Nota: O método antigo 'entrarUsuario' foi removido e substituído por este.
  // Este método retorna um Map, exatamente como o 'auth_screen.dart' espera.
  Future<Map<String, dynamic>> login(String email, String password) async {
    // O endpoint de login agora é '/login/token' como definido no login_router.py.
    final url = Uri.parse('${Config.apiUrl}/login/token');

    try {
      // O FastAPI com OAuth2PasswordRequestForm espera um 'Content-Type'
      // do tipo 'application/x-www-form-urlencoded'.
      // O pacote http do Dart faz isso automaticamente quando passamos um Map para o 'body'.
      // Os campos devem ser 'username' e 'password'.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // O corpo da requisição envia o e-mail no campo 'username'.
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Sucesso! A API retornou um token.
        final data = json.decode(response.body);
        final token = data['access_token']; // O schema de resposta é {"access_token": "...", "token_type": "bearer"}.

        print('Login bem-sucedido. Token recebido: $token');

        // TODO: Salvar o token de forma segura (ex: usando shared_preferences)
        // Por exemplo:
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('jwt_token', token);

        return {'success': true, 'token': token};
      } else {
        // Trata erros de autenticação ou outros erros do servidor.
        final errorData = json.decode(response.body);
        // A API FastAPI retorna o erro no campo 'detail'.
        final errorMessage = errorData['detail'] ?? 'Erro desconhecido ao tentar fazer login.';
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      // Trata erros de conexão (ex: API offline).
      print('Erro de conexão: $e');
      return {'success': false, 'error': 'Não foi possível conectar ao servidor.'};
    }
  }


  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    // O novo endpoint que criamos na API
    final url = Uri.parse('${Config.apiUrl}/usuarios/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // Para o registro, enviamos os dados como JSON
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': password,
        }),
      );

      if (response.statusCode == 201) { // 201 Created
        // Usuário criado com sucesso!
        return {
          'success': true,
          'message': 'Conta criada com sucesso! Por favor, faça o login.'
        };
      } else {
        // Trata erros de registro (ex: e-mail duplicado)
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Erro desconhecido ao tentar se registrar.';
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      // Trata erros de conexão
      print('Erro de conexão no registro: $e');
      return {'success': false, 'error': 'Não foi possível conectar ao servidor.'};
    }
  }

}