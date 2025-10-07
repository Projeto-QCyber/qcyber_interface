// lib/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.requestPasswordReset(_emailController.text.trim());

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Sending attempt has been made.'),
        backgroundColor: result['success'] ? MyColors.success_qcyber : MyColors.error_qcyber,
      ));
      if (result['success']) {
        Navigator.of(context).pop();
      }
    }
  }

  // Helper de estilo para os inputs, seguindo o padrão da tela de login
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
    final titleStyle = textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      // ATUALIZADO: AppBar com a identidade visual completa
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
      body: Column(
        children: [
          Expanded(
            child: Center(
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
                        Text('Account Recovery', textAlign: TextAlign.center, style: titleStyle),
                        const SizedBox(height: 16),
                        Text(
                          'Enter your email below. If it is registered in our system, we will send a link for you to reset your password.',
                          textAlign: TextAlign.center,
                          style: textStyle.copyWith(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: textStyle,
                          decoration: _inputDecoration('Your Email'),
                          validator: (v) => v!.isEmpty || !v.contains('@') ? 'Please enter a valid email' : null,
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator(color: Colors.white))
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.background_qcyber,
                                foregroundColor: MyColors.primary_qcyber,
                                padding: const EdgeInsets.symmetric(vertical: 16)
                            ),
                            onPressed: _sendResetLink,
                            child: const Text('Send Reset Link',style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ATUALIZADO: Rodapé com a logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}