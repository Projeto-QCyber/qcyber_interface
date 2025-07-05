import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zeropoint/objetos/analise.dart'; // Importe o seu modelo aqui

class DashboardService {
  // A URL da sua API de dashboard que busca os dados
  final String _baseUrl = "http://localhost:5001/api/analises";

  Future<List<Analise>> fetchAnalises() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      // Se a chamada for bem-sucedida, decodifica o JSON
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Converte a lista de JSONs em uma lista de objetos Analise
      return jsonList.map((json) => Analise.fromJson(json)).toList();
    } else {
      // Se der erro, lança uma exceção
      throw Exception('Falha ao carregar dados da API');
    }
  }
}