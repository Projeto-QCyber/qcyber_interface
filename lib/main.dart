import 'package:flutter/material.dart';
// A IMPORTAÇÃO CORRETA (agora vai funcionar)
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/screens/auth_or_home_page.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/screens/reset_password_screen.dart';
import 'package:zeropoint/services/auth_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthService authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsuariosLogados()),
      ],
      child: MyApp(authService: authService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.nomeDaAplicacao,
      debugShowCheckedModeBanner: false,


      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português (Brasil)
        // Adicione outras linguagens que você queira suportar no futuro
        // Locale('en', 'US'), // Inglês
      ],


      theme: ThemeData(
        // Seu tema continua o mesmo...
        scaffoldBackgroundColor: MyColors.background_qcyber,
        primaryColor: MyColors.background_qcyber,
        appBarTheme: AppBarTheme(
          backgroundColor: MyColors.primary_qcyber,
          titleTextStyle: TextStyle(
            color: MyColors.background_qcyber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: MyColors.background_qcyber,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: MyColors.background_qcyber,
            backgroundColor: MyColors.primary_qcyber,
          ),
        ),
      ),
      // 2. ALTERADO: O ponto de entrada agora é a nossa tela de verificação
      home: const AuthOrHomePage(),
      // 3. NOVO: Adicione rotas para navegação limpa
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MenuPage(),
      },

      onGenerateRoute: (settings) {
        // Verifica se a URL acessada é a de redefinir senha
        if (settings.name != null &&
            settings.name!.startsWith('/reset-password')) {
          final uri = Uri.parse(settings.name!);
          // Pega o valor do parâmetro 'token' da URL
          final token = uri.queryParameters['token'];

          if (token != null) {
            // Se encontrou um token, cria a rota para a tela correta
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            );
          }
        }
        // Para qualquer outra rota, deixa o Flutter usar o comportamento padrão (o `routes` acima)
        return null;
      },
    );
  }

}

// A classe GerenciadorTelas pode ser removida se não for mais usada em outro lugar.