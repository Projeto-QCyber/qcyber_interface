import 'package:zeropoint/objetos/ameaca.dart';

/// Serviço para buscar dados de ameaças.
/// POR ENQUANTO, retorna uma lista de dados mocados.
class AmeacaService {
  Future<List<Ameaca>> fetchAmeacas() async {
    // Simula uma chamada de rede
    await Future.delayed(const Duration(seconds: 1));

    // Retorna uma lista de ameaças de exemplo
    return [
      Ameaca(
        id: 1,
        titulo: "Tentativa de Acesso SSH Anómala",
        dispositivoNome: "Servidor-01",
        dispositivoHost: "192.168.1.10",
        nivelRisco: "Crítico",
        dataDeteccao: DateTime.now().subtract(const Duration(minutes: 15)),
        resumoTecnico: "Múltiplas tentativas de login falhadas na porta 22 a partir do IP 103.22.14.5.",
        explicacaoLLM: "Isto indica um possível ataque de força bruta, onde um atacante está a tentar adivinhar a sua senha de administrador. A origem do IP é de uma rede conhecida por atividades maliciosas. É crucial verificar os logs de acesso e garantir que as senhas fortes estão em vigor.",
        acoesRecomendadas: [
          "Bloquear o endereço de IP 103.22.14.5 na firewall.",
          "Verificar se o acesso SSH está limitado a IPs de confiança.",
          "Analisar os logs de autenticação para outras atividades suspeitas."
        ],
      ),
      Ameaca(
        id: 2,
        titulo: "Tráfego de Rede Incomum",
        dispositivoNome: "Estacao-Marketing-05",
        dispositivoHost: "192.168.3.22",
        nivelRisco: "Alto",
        dataDeteccao: DateTime.now().subtract(const Duration(hours: 2)),
        resumoTecnico: "Detetado um grande volume de dados a ser enviado para um endpoint desconhecido na China.",
        explicacaoLLM: "Um grande volume de dados a ser enviado para um local inesperado pode ser um sinal de exfiltração de dados, onde um malware está a roubar informações sensíveis. A comunicação com um endpoint não reconhecido aumenta a suspeita de uma infeção.",
        acoesRecomendadas: [
          "Isolar o dispositivo da rede imediatamente.",
          "Executar uma verificação completa de malware no dispositivo.",
          "Analisar o tráfego de rede para identificar a natureza dos dados enviados."
        ],
      ),
    ];
  }
}
