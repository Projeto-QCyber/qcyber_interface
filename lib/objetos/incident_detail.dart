import 'package:zeropoint/objetos/detection_history_item.dart';

class IncidentDetail extends DetectionHistoryItem {
  final int dispositivoId;
  final String resumoTecnico;
  final String explicacaoLLM;
  final List<String> acoesRecomendadas;
  final String nivelRisco;

  IncidentDetail({
    required super.id,
    required super.dataDeteccao,
    required super.tipoAtaque,
    required super.nomeDispositivo,
    required super.statusResposta,
    required this.dispositivoId,
    required this.resumoTecnico,
    required this.explicacaoLLM,
    required this.acoesRecomendadas,
    required this.nivelRisco,
  });

  factory IncidentDetail.fromJson(Map<String, dynamic> json) {
    dynamic rawAcoes = json['acoes_recomendadas'];
    List<String> parsedAcoes = [];

    if (rawAcoes is List) {
      // Cenário legado: se por acaso vier uma lista simples de strings
      parsedAcoes = rawAcoes.map((e) => e.toString()).toList();
    } else if (rawAcoes is Map) {
      // Novo cenário: explorando o objeto complexo

      // 1. Tenta extrair os planos de resposta ("plan")
      if (rawAcoes['incident_response_plans'] is List) {
        for (var item in rawAcoes['incident_response_plans']) {
          if (item is Map && item['plan'] != null) {
            String plan = item['plan'].toString().trim();
            if (plan.isNotEmpty) {
              parsedAcoes.add("Plano (${item['attack_type_label']}): $plan");
            }
          }
        }
      }

      // 2. Se não achou nenhum plano válido, tenta buscar nas sugestões
      if (parsedAcoes.isEmpty && rawAcoes['remediation_suggestions'] is List) {
        for (var item in rawAcoes['remediation_suggestions']) {
          if (item is Map && item['suggestion'] != null) {
            var sug = item['suggestion'];
            // Garante que só vai pegar se for uma String preenchida (ignora o objeto vazio {})
            if (sug is String && sug.trim().isNotEmpty) {
              parsedAcoes.add("Sugestão (${item['attack_type_label']}): $sug");
            }
          }
        }
      }

      // 3. Fallback: Se tudo falhou (ex: status "crew_failed")
      if (parsedAcoes.isEmpty) {
        parsedAcoes.add("Nenhuma ação automática recomendada (Análise LLM falhou ou pendente).");
      }
    }

    return IncidentDetail(
      id: json['id'],
      dispositivoId: json['dispositivo_id'] ?? 0,
      dataDeteccao: DateTime.parse(json['data_deteccao']),
      tipoAtaque: json['tipo_ataque'] ?? 'Desconhecido',
      nomeDispositivo: json['nome_dispositivo'] ?? 'Desconhecido',
      statusResposta: json['status_resposta'] ?? 'Desconhecido',
      resumoTecnico: json['resumo_tecnico'] ?? 'N/A',
      explicacaoLLM: json['explicacao_llm'] ?? 'Análise detalhada não disponível.',
      acoesRecomendadas: parsedAcoes, // <- Lista limpa e segura para a UI
      nivelRisco: json['nivel_risco'] ?? 'Desconhecido',
    );
  }
}