// lib/_core/services/dialog_manager_service.dart
import 'package:flutter/material.dart';

class DialogManagerService {
  bool _isDialogVisible = false;

  /// Retorna true se um diálogo gerenciado por este serviço já estiver visível.
  bool get isDialogVisible => _isDialogVisible;

  /// Marca o diálogo como visível. Deve ser chamado antes de showDialog.
  void show() {
    _isDialogVisible = true;
  }

  /// Marca o diálogo como não visível. Deve ser chamado quando o diálogo for fechado.
  void dismiss() {
    _isDialogVisible = false;
  }
}