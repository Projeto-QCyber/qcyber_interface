import 'package:flutter/material.dart';
import 'package:zeropoint/_core/services/dialog_manager_service.dart';
// NOVO: Importe o novo widget que criamos
import 'package:zeropoint/widgets/dialogs/stateful_connection_dialog_content.dart';

class ConnectionErrorDialog {
  static final _dialogManager = DialogManagerService();

  static void show(BuildContext context, {required Future<void> Function() onTryAgain}) {
    if (_dialogManager.isDialogVisible) {
      return;
    }

    if (!context.mounted) return;

    _dialogManager.show();

    // Agora, o showDialog simplesmente constrói nosso novo widget com estado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Passamos a função onTryAgain para o novo widget
        return StatefulConnectionDialogContent(onTryAgain: onTryAgain);
      },
    ).then((_) {
      // A trava ainda é liberada aqui, mas agora só depois que o diálogo
      // for fechado com sucesso pelo próprio widget.
      _dialogManager.dismiss();
    });
  }
}