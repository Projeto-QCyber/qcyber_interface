import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. IMPORTE o Provider
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart'; // 2. IMPORTE seu objeto de estado
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // ... (controllers e outras variáveis continuam iguais)
  final _emailController = TextEditingController(text: "pedrolino.landim@gmail.com");
  final _senhaController = TextEditingController(text: "123456");
  final _confirmaController = TextEditingController();
  final _nomeController = TextEditingController();
  bool _isEntrando = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  Future<void> _entrarUsuario() async {
    setState(() => _isLoading = true);

    final result = await _authService.login(
      _emailController.text,
      _senhaController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // 3. ALTERADO: Ponto principal da atualização!
      // Antes de navegar, vamos atualizar o estado do usuário logado.
      // O ideal é pegar os dados do usuário decodificando o token ou de uma rota /me da API.
      // Por enquanto, usaremos o e-mail do controller.
      Provider.of<UsuariosLogados>(context, listen: false).atualizarUsuarioLogado(
        0, // TODO: Substituir por um ID real vindo da API
        _emailController.text, // TODO: Substituir pelo nome real vindo da API
      );

      // Navega para a página principal usando a rota nomeada
      Navigator.pushReplacementNamed(context, '/home');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ocorreu um erro no login.'),
          backgroundColor: MyColors.error_qcyber,
        ),
      );
    }
  }

  // ... (o resto da classe continua exatamente igual)
  Future<void> _criarUsuario() async {
    setState(() => _isLoading = true);
    final result = await _authService.register(
      nome: _nomeController.text,
      email: _emailController.text,
      password: _senhaController.text,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registro bem-sucedido! Por favor, faça o login.'),
          backgroundColor: MyColors.success_qcyber,
        ),
      );
      setState(() => _isEntrando = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ocorreu um erro no registro.'),
          backgroundColor: MyColors.error_qcyber,
        ),
      );
    }
  }

  void _botaoEnviarClicado() {
    if (_formKey.currentState!.validate()) {
      _isEntrando ? _entrarUsuario() : _criarUsuario();
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: MyColors.textOnPrimary_qcyber.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: MyColors.textOnPrimary_qcyber, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.orangeAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // ... O build continua exatamente o mesmo
    final textStyle = const TextStyle(
      color: MyColors.textOnPrimary_qcyber,
      height: 1.5,
    );
    final titleStyle = textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Image.asset(
                Config.logoAzul,
                width: 300,
                height: 80,
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: MyColors.primary_qcyber,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _isEntrando ? "Bem-vindo" : "Criar Nova Conta",
                          textAlign: TextAlign.center,
                          style: titleStyle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_isEntrando) ...[
                        TextFormField(
                          controller: _nomeController,
                          style: textStyle,
                          decoration: _inputDecoration("Nome Completo"),
                          validator: (value) => (value == null || value.length < 3) ? "Insira um nome maior." : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextFormField(
                        controller: _emailController,
                        style: textStyle,
                        decoration: _inputDecoration("E-mail"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || !value.contains('@')) ? "Insira um e-mail válido." : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        style: textStyle,
                        decoration: _inputDecoration("Senha"),
                        validator: (value) => (value == null || value.length < 6) ? "A senha deve ter pelo menos 6 caracteres." : null,
                      ),
                      if (!_isEntrando) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmaController,
                          obscureText: true,
                          style: textStyle,
                          decoration: _inputDecoration("Confirme a senha"),
                          validator: (value) => value != _senhaController.text ? "As senhas devem ser iguais." : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: Colors.white))
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.background_qcyber,
                            foregroundColor: MyColors.primary_qcyber,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _botaoEnviarClicado,
                          child: Text(_isEntrando ? "Entrar" : "Registar"),
                        ),
                      TextButton(
                        onPressed: () => setState(() => _isEntrando = !_isEntrando),
                        child: Text(
                          _isEntrando ? "Ainda não tem conta? Registe-se" : "Já tem uma conta? Entre",
                          style: TextStyle(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versão 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MyColors.primary_qcyber.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}