import 'package:flutter/material.dart';
import 'package:zeropoint/_core/Config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/services/auth_service.dart';
import 'package:provider/provider.dart'; // Mantido para MultiProvider


void main() async {
  // Garante que o binding do Flutter esteja inicializado antes de usar qualquer serviço.
  WidgetsFlutterBinding.ensureInitialized();

  // Cria uma instância de AuthService. Essa instância será passada para MyApp.
  // A responsabilidade de AuthService em relação ao Firebase agora deve ser gerenciada
  // dentro da própria classe AuthService, ou removida de lá se não for mais necessária.
  final AuthService authService = AuthService();

  runApp(MultiProvider(
      providers: [
        // Fornece UsuariosLogados através de ChangeNotifierProvider
        ChangeNotifierProvider(create: (context) => UsuariosLogados(id: 0, nome: "")),
      ],
      // Passa a instância de AuthService para MyApp
      child: MyApp(authService: authService)
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService; // Recebe a instância de AuthService
  const MyApp({super.key, required this.authService});

  // Este widget é a raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.nomeDaAplicacao,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.fundo_app1, // Define a cor de fundo da página
        primaryColor: MyColors.fundo_app1, // Define a cor primária do tema
        appBarTheme: AppBarTheme(
          backgroundColor: MyColors.principal_app1,
          titleTextStyle: TextStyle(
            color: MyColors.fundo_app1, // Cor do texto do título
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: MyColors.fundo_app1, // Cor dos ícones
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: MyColors.fundo_app1, backgroundColor: MyColors.principal_app1, // Cor do texto e ícones
          ),
        ),
      ),
      home: AuthScreen(), // Passa authService para LoadingScreen
    );
  }
}

class GerenciadorTelas extends StatelessWidget {
  final AuthService authService; // Recebe a instância de AuthService
  GerenciadorTelas({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(); // AuthScreen pode usar authService se precisar.
  }
}
