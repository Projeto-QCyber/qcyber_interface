import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controladores para os campos do formulário
  final _emailController = TextEditingController(text: "pedrolino.landim@gmail.com");
  final _senhaController = TextEditingController(text: "123456");
  final _confirmaController = TextEditingController();
  final _nomeController = TextEditingController();

  // Variáveis de estado da UI
  bool _isEntrando = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _authService = AuthService();

  // ATUALIZADO: Lógica simplificada para o login com JWT, sem 2FA.
  Future<void> _entrarUsuario() async {
    setState(() => _isLoading = true);

    // A chamada para o serviço de login que atualizamos.
    final result = await _authService.login(
      _emailController.text,
      _senhaController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Login bem-sucedido, o token foi recebido no AuthService.
      // Navega diretamente para a página principal.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else {
      // Exibe a mensagem de erro retornada pela API.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ocorreu um erro no login.'),
          backgroundColor: MyColors.error_qcyber,
        ),
      );
    }
  }

  // ATUALIZADO: A chamada ao serviço de registro foi ajustada.
  Future<void> _criarUsuario() async {
    setState(() => _isLoading = true);

    // A chamada para o serviço de registro que implementamos.
    // O parâmetro 'enable2fa' foi removido, pois a nova função não o utiliza.
    final result = await _authService.register(
      nome: _nomeController.text,
      email: _emailController.text,
      password: _senhaController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Mostra a mensagem de sucesso e muda para a tela de login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registro bem-sucedido! Por favor, faça o login.'),
          backgroundColor: MyColors.success_qcyber,
        ),
      );
      setState(() => _isEntrando = true);
    } else {
      // Mostra a mensagem de erro retornada pela API (ex: e-mail já existe).
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

  // Função para criar a decoração dos campos de texto (sem alterações).
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