// lib/screens/auth_or_home_page.dart

import 'package:flutter/material.dart';
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // A única tarefa é verificar se o token existe
      future: TokenStorageService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tela de loading inicial do app
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Se o snapshot tem dados (o token não é nulo), vá para a MenuPage
        if (snapshot.hasData && snapshot.data != null) {
          return const MenuPage();
        }

        // Se não, vá para a tela de login
        return const AuthScreen();
      },
    );
  }
}