/// Representa um alerta de segurança ou uma ameaça detectada.
/// Contém dados mocados para fins de prototipagem da UI.
class Ameaca {
  final int id;
  final String titulo;
  final String dispositivoNome;
  final String dispositivoHost;
  final String nivelRisco; // Ex: Crítico, Alto, Médio
  final DateTime dataDeteccao;
  final String resumoTecnico;
  final String explicacaoLLM;
  final List<String> acoesRecomendadas;

  Ameaca({
    required this.id,
    required this.titulo,
    required this.dispositivoNome,
    required this.dispositivoHost,
    required this.nivelRisco,
    required this.dataDeteccao,
    required this.resumoTecnico,
    required this.explicacaoLLM,
    required this.acoesRecomendadas,
  });
}
