// lib/screens/verification_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:provider/provider.dart';   // Útil se precisarmos atualizar o estado imediatamente
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/enums/verification_type_enum.dart';
import 'package:zeropoint/_core/my_colors.dart';
// Removemos: import 'package:zeropoint/screens/MenuPage.dart'; (O Router resolve isso)
import 'package:zeropoint/services/auth_service.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';

class VerificationScreen extends StatefulWidget {
  final VerificationType verificationType;
  final String? email;
  final String? tempToken;

  const VerificationScreen({
    super.key,
    required this.verificationType,
    this.email,
    this.tempToken,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submitCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    if (widget.verificationType == VerificationType.email) {
      result = await _authService.verifyEmail(widget.email!, _codeController.text.trim());
    } else {
      result = await _authService.verify2faLogin(widget.tempToken!, _codeController.text.trim());
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Operation successful!'),
          backgroundColor: MyColors.success_qcyber,
        ),
      );

      if (widget.verificationType == VerificationType.twoFactor) {
        // CASO 1: Sucesso no 2FA (Login completo)
        // Atualizamos o Provider para refletir que o login está completo, se necessário
        // (O AppRouter fará a verificação do token e fetch do user automaticamente ao ir para a raiz)

        // Limpa a pilha e vai para a Home
        context.go('/');
      } else {
        // CASO 2: Sucesso na verificação de Email (Fluxo de Registo)
        // Retorna 'true' para quem chamou (geralmente AuthScreen)
        context.pop(true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'An error occurred.'),
          backgroundColor: MyColors.error_qcyber,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: MyColors.textOnPrimary_qcyber.withOpacity(0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: MyColors.textOnPrimary_qcyber, width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    final isEmailVerification = widget.verificationType == VerificationType.email;
    final title = isEmailVerification ? 'Verify Your Email' : 'Two-Factor Authentication';
    final description = isEmailVerification
        ? "We've sent a code to ${widget.email}. Please enter it below to activate your account."
        : "For your security, we've sent a code to your email. Please enter it to continue.";
    final textStyle = const TextStyle(color: MyColors.textOnPrimary_qcyber);

    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: MyColors.textOnPrimary_qcyber)),
        backgroundColor: MyColors.primary_qcyber,
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(Config.logoBranca, height: 30),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Image.asset(
                  Config.logoAzul,
                  width: 300,
                  height: 80,
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(color: MyColors.primary_qcyber, borderRadius: BorderRadius.circular(16)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, textAlign: TextAlign.center, style: textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(description, textAlign: TextAlign.center, style: textStyle.copyWith(color: Colors.white70)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: textStyle.copyWith(fontSize: 20, letterSpacing: 4),
                        decoration: _inputDecoration('Verification Code'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter the code.' : null,
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)) else ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: MyColors.background_qcyber, foregroundColor: MyColors.primary_qcyber, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _submitCode,
                        child: const Text('Verify', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
                      ),
                      if (isEmailVerification) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            // Lógica futura de reenvio
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resend functionality coming soon.")));
                          },
                          child: Text('Resend code', style: textStyle.copyWith(color: MyColors.textOnPrimary_qcyber.withOpacity(0.8))),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}