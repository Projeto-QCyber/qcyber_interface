import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/ameaca.dart';
import 'package:zeropoint/services/ameaca_service.dart';

class AmeacasScreen extends StatefulWidget {
  const AmeacasScreen({super.key});

  @override
  State<AmeacasScreen> createState() => _AmeacasScreenState();
}

class _AmeacasScreenState extends State<AmeacasScreen> {
  final AmeacaService _service = AmeacaService();
  late Future<List<Ameaca>> _ameacasFuture;

  @override
  void initState() {
    super.initState();
    _ameacasFuture = _service.fetchAmeacas();
  }

  Color _getColorForRisco(String risco) {
    switch (risco.toLowerCase()) {
      case 'crítico':
        return MyColors.error_qcyber;
      case 'alto':
        return MyColors.warning_qcyber;
      default:
        return MyColors.textSecondary_qcyber;
    }
  }

  // Função que exibe o modal com os detalhes da ameaça
  void _showAmeacaDetailsDialog(Ameaca ameaca) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: MyColors.card_qcyber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.security, color: _getColorForRisco(ameaca.nivelRisco)),
              const SizedBox(width: 8),
              Expanded(child: Text(ameaca.titulo)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Dispositivo:", "${ameaca.dispositivoNome} (${ameaca.dispositivoHost})"),
                _buildDetailRow("Data:", DateFormat('dd/MM/yyyy HH:mm').format(ameaca.dataDeteccao)),
                _buildDetailRow("Nível de Risco:", ameaca.nivelRisco),
                const Divider(height: 24),
                _buildSectionTitle("Análise (LLM)"),
                Text(ameaca.explicacaoLLM, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                const SizedBox(height: 16),
                _buildSectionTitle("Ações Recomendadas"),
                ...ameaca.acoesRecomendadas.map((acao) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text("• $acao", style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Fechar", style: TextStyle(color: MyColors.primary_qcyber)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Widget auxiliar para os títulos das seções no modal
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber, fontSize: 16),
      ),
    );
  }

  // Widget auxiliar para as linhas de detalhe no modal
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: MyColors.textSecondary_qcyber, fontSize: 14),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ameaças Detectadas'),
        backgroundColor: MyColors.primary_qcyber,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Config.logoBranca, width: 100),
          ),
        ],
      ),
      backgroundColor: MyColors.background_qcyber,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Ameaca>>(
              future: _ameacasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar ameaças.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma ameaça detectada.'));
                }

                final ameacas = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: ameacas.length,
                  itemBuilder: (context, index) {
                    final ameaca = ameacas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(Icons.security, color: _getColorForRisco(ameaca.nivelRisco), size: 40),
                        title: Text(ameaca.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${ameaca.dispositivoNome} - ${DateFormat('dd/MM HH:mm').format(ameaca.dataDeteccao)}"),
                        trailing: Chip(
                          label: Text(ameaca.nivelRisco, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: _getColorForRisco(ameaca.nivelRisco),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onTap: () {
                          // Chama o modal com os detalhes da ameaça selecionada
                          _showAmeacaDetailsDialog(ameaca);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Rodapé com a logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
