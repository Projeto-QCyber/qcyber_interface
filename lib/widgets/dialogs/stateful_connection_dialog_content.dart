import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'dart:async';

class StatefulConnectionDialogContent extends StatefulWidget {
  final Future<void> Function() onTryAgain;

  const StatefulConnectionDialogContent({super.key, required this.onTryAgain});

  @override
  State<StatefulConnectionDialogContent> createState() => _StatefulConnectionDialogContentState();
}

class _StatefulConnectionDialogContentState extends State<StatefulConnectionDialogContent> {
  bool _isTryingAgain = false;

  Future<void> _handleTryAgain() async {
    setState(() {
      _isTryingAgain = true;
    });

    // Adicionamos um pequeno delay para mostrar o indicador de loading,
    // tornando a experiência do usuário mais responsiva.
    await Future.delayed(const Duration(milliseconds: 500));

    // Executa a lógica de reconexão
    await widget.onTryAgain();

    // Se o widget ainda estiver montado após a tentativa, reseta o estado.
    if (mounted) {
      setState(() {
        _isTryingAgain = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Row(
        children: [
          Icon(Icons.wifi_off, color: MyColors.error_qcyber),
          SizedBox(width: 12),
          Text('Connection Error', style: TextStyle(color: MyColors.textPrimary_qcyber)),
        ],
      ),
      content: const Text(
        'Could not connect to the server. Please check your internet connection and try again.',
        style: TextStyle(color: MyColors.textSecondary_qcyber),
      ),
      actions: <Widget>[
        if (_isTryingAgain)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            onPressed: _handleTryAgain,
            child: const Text('Try Again', style: TextStyle(color: MyColors.primary_qcyber, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
