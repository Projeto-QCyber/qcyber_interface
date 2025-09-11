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
    return IncidentDetail(
      id: json['id'],
      dispositivoId: json['dispositivo_id'],
      dataDeteccao: DateTime.parse(json['data_deteccao']),
      tipoAtaque: json['tipo_ataque'],
      nomeDispositivo: json['nome_dispositivo'],
      statusResposta: json['status_resposta'],
      resumoTecnico: json['resumo_tecnico'] ?? 'N/A',
      explicacaoLLM: json['explicacao_llm'] ?? 'Análise detalhada não disponível.',
      acoesRecomendadas: List<String>.from(json['acoes_recomendadas'] ?? []),
      nivelRisco: json['nivel_risco'] ?? 'Desconhecido',
    );
  }
}