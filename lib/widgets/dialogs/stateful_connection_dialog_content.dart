import 'package:flutter/material.dart';

import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/services/auth_service.dart';

class StatefulConnectionDialogContent extends StatefulWidget {
  final Future<void> Function() onTryAgain;

  const StatefulConnectionDialogContent({
    super.key,
    required this.onTryAgain,
  });

  @override
  State<StatefulConnectionDialogContent> createState() => _StatefulConnectionDialogContentState();
}

class _StatefulConnectionDialogContentState extends State<StatefulConnectionDialogContent> {
  bool _isTryingAgain = false;

  bool _isLoggingOut = false;

  final AuthService _authService = AuthService();

  Future<void> _handleTryAgain() async {
    setState(() {
      _isTryingAgain = true;
    });

    try {
      await widget.onTryAgain();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTryingAgain = false;
        });
      }
    }
  }

  // ATUALIZADO: A lógica de logout agora gerencia o estado de loading.
  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {

      if (mounted) {
        _authService.logout(context);
      }
    } catch (e) {
      // Se o logout falhar (muito raro), apenas reativamos o botão.
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.wifi_off_rounded, color: MyColors.error_qcyber, size: 48),
      title: const Text('Falha na Conexão', style: TextStyle(color: MyColors.textPrimary_qcyber)),
      content: const Text(
        'Não foi possível se comunicar com o servidor. Verifique sua conexão ou tente novamente.',
        style: TextStyle(color: MyColors.textSecondary_qcyber),
      ),
      actions: <Widget>[
        OutlinedButton(
          // Botão é desabilitado durante qualquer ação
          onPressed: _isTryingAgain || _isLoggingOut ? null : _handleTryAgain,
          child: _isTryingAgain
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('TENTAR NOVAMENTE', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: MyColors.primary_qcyber),
          // Botão é desabilitado durante qualquer ação
          onPressed: _isTryingAgain || _isLoggingOut ? null : _handleLogout,
          // ATUALIZADO: Mostra um loading circular durante o logout
          child: _isLoggingOut
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('VOLTAR AO LOGIN', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
        ),
      ],
    );
  }
}