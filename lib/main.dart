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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importante para datas em PT-BR
import 'package:intl/date_symbol_data_local.dart'; // Importante para datas em PT-BR

import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/app_router.dart'; // O arquivo que acabamos de criar

import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/services/auth_service.dart';
import 'package:zeropoint/services/token_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a formatação de datas (útil se usar DatePicker ou formatação de moeda)
  await initializeDateFormatting('pt_BR', null);

  // Instanciamos o AuthService aqui para injetá-lo no Provider
  final AuthService authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        // O UsuariosLogados gerencia o estado da sessão na memória
        ChangeNotifierProvider(create: (context) => UsuariosLogados()),

        // Injetamos os serviços para que qualquer tela possa acessá-los
        Provider<AuthService>(create: (_) => authService),
        Provider<TokenStorageService>(create: (_) => TokenStorageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos nosso Roteador Inteligente
    // Ele não precisa receber parâmetros aqui porque ele mesmo acessa o Provider/Storage internamente
    final appRouter = AppRouter();

    return MaterialApp.router( // <--- A MUDANÇA PRINCIPAL É AQUI
      title: Config.nomeDaAplicacao,
      debugShowCheckedModeBanner: false,

      // Configuração de Idioma (PT-BR)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      // Tema
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.background_qcyber,
        primaryColor: MyColors.background_qcyber, // Ajuste conforme seu MyColors atual
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

      // Conectando o GoRouter ao Flutter
      routerConfig: appRouter.router,
    );
  }
}