import 'package:flutter/material.dart';
// NOVO: Importe o serviço de armazenamento de token que criamos.
import 'package:zeropoint/_core/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuariosLogados extends ChangeNotifier{

  // ALTERADO: Tornamos os campos privados e "nullable" (podem ser nulos).
  // Isso permite que a classe represente um estado de "usuário deslogado".
  int? _id;
  String? _nome;

  // NOVO: Getters públicos para acessar os dados de forma segura.
  int? get id => _id;
  String? get nome => _nome;

  // NOVO: Um getter muito útil para a UI saber se o usuário está logado ou não.
  bool get isLogged => _id != null;

  // NOVO: Instância do nosso serviço de token.
  final TokenStorageService _tokenStorage = TokenStorageService();

  // ALTERADO: O construtor agora não exige parâmetros e inicia o usuário como deslogado.
  UsuariosLogados() {
    _id = null;
    _nome = null;
  }

  // O método para atualizar o usuário ao fazer login continua o mesmo na sua função.
  void atualizarUsuarioLogado(int idr, String nomer) {
    _id = idr;
    _nome = nomer;
    notifyListeners();
  }

  // NOVO: O método de logout que faltava.
  Future<void> logout() async {
    // Abordagem padrão (a que já temos):
    // await _tokenStorage.deleteToken();

    // Abordagem Agressiva (use se necessário):
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Apaga TUDO do SharedPreferences
    print("Armazenamento local completamente limpo.");

    // O resto da função continua igual
    _id = null;
    _nome = null;
    notifyListeners();
  }
}