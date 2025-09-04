import 'dart:convert';

// Função para decodificar o JSON de forma segura
DashboardSummary dashboardSummaryFromJson(String str) => DashboardSummary.fromJson(json.decode(str));

class DashboardSummary {
  final Kpis kpis;
  final List<AtaquePorTipo> ataquesPorTipo;
  final List<UltimaDeteccao> ultimasDeteccoes;
  final List<DeteccoesPorHora> deteccoesPorHora;
  final List<DispositivosAtacados> dispositivosAtacados;
  final List<IncidentesPorRisco> incidentesPorRisco;


  DashboardSummary({
    required this.kpis,
    required this.ataquesPorTipo,
    required this.ultimasDeteccoes,
    required this.deteccoesPorHora,
    required this.dispositivosAtacados,
    required this.incidentesPorRisco,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
    kpis: Kpis.fromJson(json["kpis"]),
    ataquesPorTipo: List<AtaquePorTipo>.from(json["ataques_por_tipo"].map((x) => AtaquePorTipo.fromJson(x))),
    ultimasDeteccoes: List<UltimaDeteccao>.from(json["ultimas_deteccoes"].map((x) => UltimaDeteccao.fromJson(x))),
    deteccoesPorHora: List<DeteccoesPorHora>.from(json["deteccoes_por_hora"].map((x) => DeteccoesPorHora.fromJson(x))),
    dispositivosAtacados: List<DispositivosAtacados>.from(json["dispositivos_atacados"].map((x) => DispositivosAtacados.fromJson(x))),
    incidentesPorRisco: List<IncidentesPorRisco>.from(json["incidentes_por_risco"].map((x) => IncidentesPorRisco.fromJson(x))),

  );
}

class Kpis {
  final int totalDeteccoes;
  final int acoesExecutadas;
  final int dispositivosAtivos;
  final int incidentesCriados;

  Kpis({
    required this.totalDeteccoes,
    required this.acoesExecutadas,
    required this.dispositivosAtivos,
    required this.incidentesCriados,
  });

  factory Kpis.fromJson(Map<String, dynamic> json) => Kpis(
    totalDeteccoes: json["total_deteccoes"],
    acoesExecutadas: json["acoes_executadas"],
    dispositivosAtivos: json["dispositivos_ativos"],
    incidentesCriados: json["incidentes_criados"],
  );
}

class AtaquePorTipo {
  final String nomeAtaque;
  final int total;
  final String descricao;

  AtaquePorTipo({
    required this.nomeAtaque,
    required this.total,
    required this.descricao,
  });

  factory AtaquePorTipo.fromJson(Map<String, dynamic> json) => AtaquePorTipo(
    nomeAtaque: json["nome_ataque"],
    total: json["total"],
    descricao: json["descricao"],
  );
}

class UltimaDeteccao {
  final int id;
  final DateTime dataDeteccao;
  final String nomeDispositivo;
  final String tipoAtaque;
  final String statusResposta;

  UltimaDeteccao({
    required this.id,
    required this.dataDeteccao,
    required this.nomeDispositivo,
    required this.tipoAtaque,
    required this.statusResposta,
  });

  factory UltimaDeteccao.fromJson(Map<String, dynamic> json) => UltimaDeteccao(
    id: json["id"],
    dataDeteccao: DateTime.parse(json["data_deteccao"]),
    nomeDispositivo: json["nome_dispositivo"],
    tipoAtaque: json["tipo_ataque"],
    statusResposta: json["status_resposta"],
  );
}

class DeteccoesPorHora {
  final DateTime hora;
  final int total;

  DeteccoesPorHora({ required this.hora, required this.total });

  factory DeteccoesPorHora.fromJson(Map<String, dynamic> json) => DeteccoesPorHora(
    hora: DateTime.parse(json["hora"]),
    total: json["total"],
  );
}

class DispositivosAtacados {
  final String nomeDispositivo;
  final int total;

  DispositivosAtacados({ required this.nomeDispositivo, required this.total });

  factory DispositivosAtacados.fromJson(Map<String, dynamic> json) => DispositivosAtacados(
    nomeDispositivo: json["nome_dispositivo"],
    total: json["total"],
  );
}

class IncidentesPorRisco {
  final String nivelRisco;
  final int total;

  IncidentesPorRisco({ required this.nivelRisco, required this.total });

  factory IncidentesPorRisco.fromJson(Map<String, dynamic> json) => IncidentesPorRisco(
    nivelRisco: json["nivel_risco"],
    total: json["total"],
  );
}

class AcaoDetail {
  final DateTime dataAcaoExecutada;
  final String? acaoParametro;
  final String nomeAcao;

  AcaoDetail({required this.dataAcaoExecutada, this.acaoParametro, required this.nomeAcao});

  factory AcaoDetail.fromJson(Map<String, dynamic> json) => AcaoDetail(
    dataAcaoExecutada: DateTime.parse(json["data_acao_executada"]),
    acaoParametro: json["acao_parametro"],
    nomeAcao: json["nome_acao"],
  );
}

class IncidenteDetail {
  final String titulo;
  final String nivelRisco;
  // final String nomeDispositivo;
  final DateTime dataCriacao;

  IncidenteDetail({required this.titulo, required this.nivelRisco, required this.dataCriacao});

  factory IncidenteDetail.fromJson(Map<String, dynamic> json) => IncidenteDetail(
    titulo: json["titulo"],
    nivelRisco: json["nivel_risco"],
    dataCriacao: DateTime.parse(json["data_criacao"]),
  );
}

class DispositivoDetail {
  final String nome;
  final String host;

  DispositivoDetail({required this.nome, required this.host});

  factory DispositivoDetail.fromJson(Map<String, dynamic> json) => DispositivoDetail(
    nome: json["nome"],
    host: json["host"],
  );
}