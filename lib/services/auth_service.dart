// Código suprimido

import 'dart:async';
import 'dart:convert';


import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zeropoint/_core/Config.dart';

class AuthService {

  // Controlador de stream para emitir eventos de autenticação
  final _authController = StreamController<bool>();

  // Stream para ouvir as alterações de autenticação
  Stream<bool> get authChanges => _authController.stream;

  Future<String?> entrarUsuario({required BuildContext context, required String email, required String senha}) async {
    //return "s";
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api-interface/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );
      //print(response.body);
      if (response.statusCode == 200) {

        // Login bem-sucedido
        Map<String, dynamic> data = json.decode(response.body);

        // Extrair o ID e o email do usuário
        String id = data['usuario_Id'];
        String userEmail = data['usuario_email'];

        print('ID do usuário: $id');
        print('Email do usuário: $userEmail');

        // Atualize o provider com os novos dados

        Provider.of<UsuariosLogados>(context, listen: false).atualizarUsuarioLogado(int.parse(id), userEmail);


        // Login bem-sucedido
        return "s";
      } else if (response.statusCode == 401) {
        // Credenciais inválidas
        return 'Credenciais inválidas';
      } else {
        // Outro erro
        print(response.body);
        return 'Erro durante a autenticação';
      }
    } catch (e) {
      print(e);
      // Lidar com erros de conexão ou outros
      return 'Erro de conexão: $e';
    }
  }


  // Método para fazer logout
  Future<void> signOut() async {
    // Sua lógica de logout aqui
    // ...

    // Emite false no stream indicando que o usuário não está autenticado
    _authController.add(false);
  }

  // Fechar o controlador de stream ao finalizar
  void dispose() {
    _authController.close();
  }

}
