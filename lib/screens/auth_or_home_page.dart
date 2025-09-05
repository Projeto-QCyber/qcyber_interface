// lib/screens/auth_or_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/MenuPage.dart'; // Sua página principal
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart';

class AuthOrHomePage extends StatefulWidget {
  const AuthOrHomePage({super.key});

  @override
  State<AuthOrHomePage> createState() => _AuthOrHomePageState();
}

class _AuthOrHomePageState extends State<AuthOrHomePage> {
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Função que verifica o token e busca os dados do usuário
  Future<bool> _checkLoginStatus() async {
    // 1. Verifica se o token existe
    String? token = await _tokenStorage.getToken();

    if (token == null) {
      return false; // Não está logado
    }

    // 2. Se o token existe, podemos decodificá-lo ou chamar uma API
    //    para pegar os dados do usuário e atualizar o provider.
    //    (Aqui usaremos dados de exemplo)
    if (mounted) {
      // Atualiza o provider com os dados do usuário "persistido"
      Provider.of<UsuariosLogados>(context, listen: false)
          .atualizarUsuarioLogado(1, "Usuário"); // TODO: Use dados reais do token ou de uma API /me
    }

    return true; // Está logado
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto verifica, mostramos uma tela de loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          // Se Future retornou true, o usuário está logado
          return const MenuPage();
        } else {
          // Caso contrário, vai para a tela de autenticação
          return const AuthScreen();
        }
      },
    );
  }
}