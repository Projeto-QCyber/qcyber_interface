// lib/services/dispositivo_service.dart

import 'package:zeropoint/objetos/dispositivo.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/config.dart'; // Ajuste o import
import 'package:zeropoint/_core/services/token_storage_service.dart'; // Ajuste o import


class DispositivoService {
  final String _baseUrl = "${Config.apiUrl}/dispositivos";
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Busca a lista de todos os dispositivos cadastrados.
  Future<List<Dispositivo>> fetchDispositivos() async {
    final uri = Uri.parse(_baseUrl);
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Usamos utf8.decode para garantir a correta interpretação de caracteres especiais
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Dispositivo.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar dispositivos. Status: ${response.statusCode}');
    }
  }

  /// Cria um novo dispositivo.
  Future<Dispositivo> createDispositivo(String nome, String host, String? localizacao) async {
    final uri = Uri.parse(_baseUrl);
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'nome': nome,
      'host': host,
      'localizacao': localizacao,
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 201) {
      return Dispositivo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      // Adicionar log para depuração
      print("Erro ao criar dispositivo: ${response.body}");
      throw Exception('Falha ao criar dispositivo. Status: ${response.statusCode}');
    }
  }

  /// Atualiza as informações de um dispositivo existente.
  Future<Dispositivo> updateDispositivo(int id, String nome, String? localizacao) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'nome': nome,
      'localizacao': localizacao,
    });

    final response = await http.put(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return Dispositivo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print("Erro ao atualizar dispositivo: ${response.body}");
      throw Exception('Falha ao atualizar dispositivo. Status: ${response.statusCode}');
    }
  }
}