import 'package:flutter/material.dart';
import 'package:zeropoint/_core/Config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/services/auth_service.dart';
import 'package:provider/provider.dart'; // Mantido para MultiProvider

// As importações do Firebase foram removidas:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:zeropoint/firebase_options.dart';

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
      // A home agora é LoadingScreen. Ela gerenciará sua própria navegação
      // após sua duração de exibição.
      home: LoadingScreen(authService: authService), // Passa authService para LoadingScreen
    );
  }
}

class GerenciadorTelas extends StatelessWidget {
  final AuthService authService; // Recebe a instância de AuthService
  GerenciadorTelas({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    ///return Testeapp();
    return AuthScreen(); // AuthScreen pode usar authService se precisar.
  }
}

class LoadingScreen extends StatefulWidget {
  final AuthService authService; // Recebe a instância de AuthService
  const LoadingScreen({super.key, required this.authService}); // Construtor para receber

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startImageRotation(); // Inicia a rotação das imagens

    // Após um atraso fixo, navega para GerenciadorTelas.
    // A duração pode ser ajustada com base no tempo que você deseja que a tela de splash seja exibida.
    Future.delayed(const Duration(seconds: 4), () { // Ex: 4 segundos para a tela de splash
      if (mounted) { // Verifica se o widget ainda está na árvore de widgets antes de navegar
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // Passa a instância de AuthService recebida por LoadingScreen para GerenciadorTelas
            builder: (context) => GerenciadorTelas(authService: widget.authService),
          ),
        );
      }
    });
  }

  // Função para rotacionar continuamente as imagens
  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 1), () { // Troca de imagem a cada 1 segundo
      if (mounted) { // Somente atualiza o estado se o widget ainda estiver na árvore de widgets
        setState(() {
          _currentIndex = (_currentIndex + 1) % 4; // Cicla entre 4 imagens
        });
        _startImageRotation(); // Chama a si mesma recursivamente para continuar a rotação
      }
    });
  }

  @override
  void dispose() {
    // Não há timers explícitos para cancelar, pois Future.delayed lida com isso implicitamente.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lista de caminhos das imagens de assets
    final images = [
      'assets/imagens/lesc.png',
      'assets/imagens/deti.png',
      'assets/imagens/ufc.png',
      'assets/imagens/biomedical.png',
    ];

    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1), // Duração da animação para a transição da imagem
          child: Image.asset(
            images[_currentIndex],
            key: ValueKey<int>(_currentIndex), // A chave é crucial para AnimatedSwitcher funcionar corretamente
          ),
        ),
      ),
    );
  }
}
