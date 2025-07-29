import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/_core/Config.dart';
import 'package:zeropoint/objetos/dispositivo.dart';

class DispositivoService {
  final String _baseUrl = "${Config.apiUrl}/api-interface/dispositivos";

  Future<List<Dispositivo>> fetchDispositivos() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Dispositivo.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar dispositivos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<bool> createDispositivo({
    required String nome,
    required String host,
    String? localizacao,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nome': nome,
          'host': host,
          'localizacao': localizacao,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
