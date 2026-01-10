// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para context.go e context.push
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/enums/verification_type_enum.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoginMode = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: MyColors.error_qcyber),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // ======================================================
    // MODO LOGIN
    // ======================================================
    if (_isLoginMode) {
      final result = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim()
      );

      if (!mounted) return;

      if (result['success']) {
        // CASO 1: Precisa de 2FA
        if (result['requires_2fa']) {
          context.push('/verify', extra: {
            'verificationType': VerificationType.twoFactor,
            'tempToken': result['temp_token'],
            'email': _emailController.text.trim(),
          });
        }
        // CASO 2: Login direto (Sucesso)
        else {
          // Use 'go' para limpar o histórico de login e ir para a raiz
          context.go('/');
        }
      } else {
        // CASO 3: Email não verificado (Erro 403)
        if (result['requires_email_verification'] == true) {
          _showError(result['error']);

          context.push('/verify', extra: {
            'verificationType': VerificationType.email,
            'email': _emailController.text.trim(),
          });
        } else {
          _showError(result['error']);
        }
      }
    }
    // ======================================================
    // MODO REGISTRO
    // ======================================================
    else {
      final result = await _authService.register(
        nome: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        // Navega para verificação e aguarda o retorno (se o usuário voltar)
        await context.push('/verify', extra: {
          'verificationType': VerificationType.email,
          'email': result['email'],
        });

        // Se o usuário voltar da tela de verificação, voltamos para a tela de Login
        if (mounted) {
          setState(() {
            _isLoginMode = true;
            _nameController.clear();
            _confirmPasswordController.clear();
            _passwordController.clear();
          });

          // --- MENSAGEM TRADUZIDA AQUI ---
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful! Please log in after verifying your email.")),
          );
        }
      } else {
        _showError(result['error']);
      }
    }

    if(mounted) setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: MyColors.textOnPrimary_qcyber.withOpacity(0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: MyColors.textOnPrimary_qcyber, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: MyColors.error_qcyber)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: MyColors.error_qcyber, width: 2)),
    errorStyle: const TextStyle(color: MyColors.error_qcyber),
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(color: MyColors.textOnPrimary_qcyber, height: 1.5);
    final titleStyle = textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0), child: Image.asset(Config.logoAzul, height: 60)),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(color: MyColors.primary_qcyber, borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_isLoginMode ? "Welcome" : "Create New Account", textAlign: TextAlign.center, style: titleStyle),
                      ),
                      const SizedBox(height: 16),
                      if (!_isLoginMode) ...[
                        TextFormField(controller: _nameController, style: textStyle, decoration: _inputDecoration("Full Name"), validator: (v) => v!.isEmpty ? 'Please enter a name' : null),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(controller: _emailController, style: textStyle, decoration: _inputDecoration("Email"), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Please enter a valid email' : null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _passwordController, obscureText: true, style: textStyle, decoration: _inputDecoration("Password"), validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters long' : null),
                      if (!_isLoginMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(controller: _confirmPasswordController, obscureText: true, style: textStyle, decoration: _inputDecoration("Confirm Password"), validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
                      ],
                      const SizedBox(height: 24),
                      if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)) else ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: MyColors.background_qcyber, foregroundColor: MyColors.primary_qcyber, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _submit,
                        child: Text(_isLoginMode ? "Sign In" : "Create Account", style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
                      ),
                      TextButton(
                        onPressed: () { if (_isLoading) return; setState(() => _isLoginMode = !_isLoginMode); },
                        child: Text(_isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Sign in", style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_isLoading) return;
                          context.push('/forgot-password');
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(color: MyColors.textOnPrimary_qcyber.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text('Version 0.1.0', textAlign: TextAlign.center, style: TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}