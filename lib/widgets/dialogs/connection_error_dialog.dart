import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/screens/auth_screen.dart';

class ConnectionErrorDialog {
  /// Exibe um diálogo de erro de conexão padronizado.
  ///
  /// [context] O BuildContext da tela que está chamando.
  /// [onTryAgain] A função a ser executada quando o botão "Tentar Novamente" for pressionado.
  static void show(BuildContext context, {required VoidCallback onTryAgain}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede o usuário de fechar clicando fora
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: MyColors.card_qcyber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: const Icon(Icons.wifi_off_rounded, color: MyColors.error_qcyber, size: 48),
          title: const Text('Falha na Conexão', style: TextStyle(color: MyColors.textPrimary_qcyber)),
          content: const Text(
            'Não foi possível se comunicar com o servidor. Verifique sua conexão ou se a API está online.',
            style: TextStyle(color: MyColors.textSecondary_qcyber),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('TENTAR NOVAMENTE', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
                onTryAgain(); // Executa a função de callback
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MyColors.primary_qcyber),
              child: const Text('VOLTAR AO LOGIN', style: TextStyle(color: MyColors.textOnPrimary_qcyber)),
              onPressed: () {
                // Navega para a tela de login e remove todas as outras telas da pilha
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}