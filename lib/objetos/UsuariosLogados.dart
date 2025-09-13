import 'package:flutter/material.dart';
import 'package:zeropoint/_core/services/token_storage_service.dart'; // Garanta que este caminho está correto

class UsuariosLogados extends ChangeNotifier {
  int? _id;
  String? _nome;
  bool _isAdmin = false; // ADICIONADO: Campo para permissão de admin

  // Getters públicos para acessar os dados de forma segura
  int? get id => _id;
  String? get nome => _nome;
  bool get isAdmin => _isAdmin;

  // Getter para a UI saber se há um usuário logado
  bool get isLogged => _id != null;

  final TokenStorageService _tokenStorage = TokenStorageService();

  // Construtor inicia o usuário como deslogado
  UsuariosLogados() {
    _id = null;
    _nome = null;
    _isAdmin = false;
  }

  /// Atualiza os dados do usuário no momento do login.
  void atualizarUsuarioLogado({
    required int id,
    required String nome,
    required bool isAdmin, // ADICIONADO: Parâmetro para admin
  }) {
    _id = id;
    _nome = nome;
    _isAdmin = isAdmin;
    notifyListeners(); // Notifica a UI que o estado do usuário mudou
  }

  /// Limpa os dados do usuário e o token armazenado.
  Future<void> logout() async {
    await _tokenStorage.deleteToken(); // Apaga o token JWT do armazenamento seguro

    // Limpa os dados do estado local
    _id = null;
    _nome = null;
    _isAdmin = false;
    notifyListeners(); // Notifica a UI que o usuário fez logout
  }
}