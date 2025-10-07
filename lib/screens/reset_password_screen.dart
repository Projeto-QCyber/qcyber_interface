// lib/screens/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  // O token será recebido da URL
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Chama o serviço para efetivar a troca de senha na API
    final result = await _authService.performPasswordReset(
      token: widget.token,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] ?? (result['success'] ? 'Password changed successfully!' : 'An error occurred.')),
      backgroundColor: result['success'] ? MyColors.success_qcyber : MyColors.error_qcyber,
    ));

    if (result['success']) {
      // Se deu certo, podemos enviar o usuário para a tela de login.
      // O popUntil remove todas as telas da pilha até encontrar a de login.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // Helper de estilo para os inputs, seguindo o padrão
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) => InputDecoration(
    labelText: label,
    suffixIcon: suffixIcon,
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
    final titleStyle = textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Config.logoBranca, width: 100),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(color: MyColors.primary_qcyber, borderRadius: BorderRadius.circular(16)),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create a New Password', textAlign: TextAlign.center, style: titleStyle),
                  const SizedBox(height: 16),
                  Text(
                    'Your new password must be strong and different from previous ones.',
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 24),
                  // Campo Nova Senha
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _isPasswordObscured,
                    style: textStyle,
                    decoration: _inputDecoration(
                      'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                    validator: (v) => (v?.length ?? 0) < 6 ? 'Password must be at least 6 characters long' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo Confirmar Senha
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmObscured,
                    style: textStyle,
                    decoration: _inputDecoration(
                      'Confirm New Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                        onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                      ),
                    ),
                    validator: (v) {
                      if (v != _newPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.white))
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.background_qcyber,
                        foregroundColor: MyColors.primary_qcyber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitNewPassword,
                      child: const Text('Save New Password', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}