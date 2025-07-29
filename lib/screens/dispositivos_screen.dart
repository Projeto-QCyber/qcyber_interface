import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/dispositivo.dart';
import 'package:zeropoint/services/dispositivo_service.dart';

class DispositivosScreen extends StatefulWidget {
  const DispositivosScreen({super.key});

  @override
  State<DispositivosScreen> createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  final DispositivoService _service = DispositivoService();
  late Future<List<Dispositivo>> _dispositivosFuture;

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _hostController = TextEditingController();
  final _localController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshDispositivos();
  }

  void _refreshDispositivos() {
    setState(() {
      _dispositivosFuture = _service.fetchDispositivos();
    });
  }

  Future<void> _addDispositivo(BuildContext dialogContext) async {
    if (_formKey.currentState!.validate()) {
      final success = await _service.createDispositivo(
        nome: _nomeController.text,
        host: _hostController.text,
        localizacao: _localController.text,
      );

      if (mounted) Navigator.of(dialogContext).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Dispositivo cadastrado com sucesso!' : 'Falha ao cadastrar dispositivo.'),
            backgroundColor: success ? MyColors.success_qcyber : MyColors.error_qcyber,
          ),
        );

        if (success) {
          _refreshDispositivos();
        }
      }
    }
  }

  void _showAddDeviceDialog() {
    _nomeController.clear();
    _hostController.clear();
    _localController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cadastrar Novo Dispositivo", style: TextStyle(color: MyColors.textPrimary_qcyber)),
          backgroundColor: MyColors.card_qcyber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome do Dispositivo (ex: Servidor-01)'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hostController,
                    decoration: const InputDecoration(labelText: 'Host (ex: 192.168.1.10)'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _localController,
                    decoration: const InputDecoration(labelText: 'Localização (ex: Datacenter A)'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: MyColors.textSecondary_qcyber)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary_qcyber,
                foregroundColor: MyColors.textOnPrimary_qcyber,
              ),
              child: const Text("Adicionar"),
              onPressed: () => _addDispositivo(dialogContext),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Dispositivos'),
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
            // Adicionado Stack para o efeito de fade
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildListaCard(),
                ),
                // Widget que cria o efeito de fade/esfumaçado
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50.0,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            MyColors.background_qcyber.withOpacity(0.0),
                            MyColors.background_qcyber,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        backgroundColor: MyColors.primary_qcyber,
        tooltip: 'Adicionar Dispositivo',
        child: const Icon(Icons.add, color: MyColors.textOnPrimary_qcyber),
      ),
    );
  }

  Widget _buildListaCard() {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dispositivos Cadastrados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Dispositivo>>(
                future: _dispositivosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar dispositivos.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum dispositivo cadastrado.'));
                  }
                  final dispositivos = snapshot.data!;
                  return ListView.separated(
                    // Adiciona padding na parte inferior para não ficar sob o fade
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: dispositivos.length,
                    separatorBuilder: (context, index) => const Divider(color: MyColors.border_qcyber),
                    itemBuilder: (context, index) {
                      final d = dispositivos[index];
                      return ListTile(
                        leading: const Icon(Icons.computer, color: MyColors.primary_qcyber),
                        title: Text(d.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${d.host} - ${d.localizacao ?? 'Sem localização'}"),
                        trailing: Text(d.status, style: TextStyle(color: d.status == 'Ativo' ? MyColors.success_qcyber : MyColors.error_qcyber)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
