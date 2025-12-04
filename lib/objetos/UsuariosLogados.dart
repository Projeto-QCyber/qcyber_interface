// lib/objetos/UsuariosLogados.dart

import 'package:flutter/material.dart';

class UsuariosLogados extends ChangeNotifier {
  int id = 0;
  String nome = '';
  String email = '';
  bool isAdmin = false;
  bool emailVerificado = false;
  bool doisFatoresAtivo = false;

  // Controle de sessão local (volátil)
  bool sessaoVerificadaPor2FA = false;

  void atualizarUsuarioLogado({
    required int id,
    required String nome,
    required String email,
    required bool isAdmin,
    required bool emailVerificado,
    required bool doisFatoresAtivo,
  }) {
    this.id = id;
    this.nome = nome;
    this.email = email;
    this.isAdmin = isAdmin;
    this.emailVerificado = emailVerificado;
    this.doisFatoresAtivo = doisFatoresAtivo;

    // Se o usuário não tem 2FA ativado, a sessão é válida automaticamente
    if (!doisFatoresAtivo) {
      this.sessaoVerificadaPor2FA = true;
    }

    notifyListeners();
  }

  void marcarSessaoComoVerificada() {
    if (!sessaoVerificadaPor2FA) {
      sessaoVerificadaPor2FA = true;
      notifyListeners();
    }
  }

  // Isso resolve o erro "The method 'limparUsuario' isn't defined"
  void limparUsuario() {
    id = 0;
    nome = '';
    email = '';
    isAdmin = false;
    emailVerificado = false;
    doisFatoresAtivo = false;
    sessaoVerificadaPor2FA = false;
    notifyListeners();
  }


}