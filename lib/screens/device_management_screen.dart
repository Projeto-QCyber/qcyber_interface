// lib/screens/device_management_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/objetos/dispositivo.dart';
// Removemos: import 'package:zeropoint/screens/device_history_detail_screen.dart'; (O Router resolve isso)
import 'package:zeropoint/screens/generic_history_screen.dart'; // Mantido caso precise de referência futura
import 'package:zeropoint/services/dispositivo_service.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final DispositivoService _apiService = DispositivoService();
  final TextEditingController _searchController = TextEditingController();

  List<Dispositivo> _allDispositivos = [];
  List<Dispositivo> _filteredDispositivos = [];
  Future<void>? _fetchFuture;

  @override
  void initState() {
    super.initState();
    _refreshDispositivos();
    _searchController.addListener(_filterDispositivos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshDispositivos() async {
    setState(() {
      _fetchFuture = _apiService.fetchDispositivos().then((data) {
        if (mounted) {
          setState(() {
            _allDispositivos = data;
            // Garante que o filtro seja aplicado se já houver texto na busca
            _filterDispositivos();
          });
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching devices: $error"), backgroundColor: MyColors.error_qcyber),
          );
        }
      });
    });
  }

  void _filterDispositivos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDispositivos = _allDispositivos.where((d) {
        return d.nome.toLowerCase().contains(query) ||
            d.host.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showDeviceDialog({Dispositivo? dispositivo}) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: dispositivo?.nome);
    final hostController = TextEditingController(text: dispositivo?.host);
    final localController = TextEditingController(text: dispositivo?.localizacao);
    final isEditing = dispositivo != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: MyColors.card_qcyber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            isEditing ? "Edit Device" : "Add Device",
            style: const TextStyle(color: MyColors.textPrimary_qcyber),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    style: const TextStyle(color: MyColors.textPrimary_qcyber),
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required field' : null,
                  ),
                  TextFormField(
                    controller: hostController,
                    readOnly: isEditing,
                    style: TextStyle(color: isEditing ? MyColors.textSecondary_qcyber : MyColors.textPrimary_qcyber),
                    decoration: const InputDecoration(labelText: 'Host'),
                    validator: (v) => v!.isEmpty ? 'Required field' : null,
                  ),
                  TextFormField(
                    controller: localController,
                    style: const TextStyle(color: MyColors.textPrimary_qcyber),
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              // ATUALIZADO: context.pop() via GoRouter (usando dialogContext para garantir o escopo)
              onPressed: () => dialogContext.pop(),
              child: const Text("Cancel", style: TextStyle(color: MyColors.textSecondary_qcyber)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary_qcyber,
                foregroundColor: MyColors.textOnPrimary_qcyber,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (isEditing) {
                      await _apiService.updateDispositivo(
                          dispositivo.id, nomeController.text, localController.text);
                    } else {
                      await _apiService.createDispositivo(
                          nomeController.text, hostController.text, localController.text);
                    }
                    if (mounted) dialogContext.pop(); // Fecha o dialog
                    _refreshDispositivos(); // Atualiza a lista
                  } catch (e) {
                    if(mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: MyColors.error_qcyber),
                      );
                    }
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: const Text('Device Management'),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [ Padding( padding: const EdgeInsets.all(8.0), child: Image.asset(Config.logoBranca, width: 100), ), ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: MyColors.textPrimary_qcyber),
              decoration: InputDecoration(
                hintText: 'Search by name or host...',
                hintStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
                prefixIcon: const Icon(Icons.search, color: MyColors.textSecondary_qcyber),
                filled: true,
                fillColor: MyColors.card_qcyber,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.border_qcyber)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyColors.border_qcyber)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _fetchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allDispositivos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: MyColors.textSecondary_qcyber)));
                }
                if (_allDispositivos.isEmpty) {
                  return const Center(child: Text("No devices registered.", style: TextStyle(color: MyColors.textPrimary_qcyber)));
                }

                final dispositivos = _filteredDispositivos;
                if(dispositivos.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(child: Text("No devices found for the search.", style: TextStyle(color: MyColors.textPrimary_qcyber)));
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                      itemCount: dispositivos.length,
                      itemBuilder: (context, index) {
                        final d = dispositivos[index];
                        return Card(
                          color: MyColors.card_qcyber,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: MyColors.border_qcyber)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            // ATUALIZADO: Navegação via rota nomeada com parâmetro e objeto extra
                            onTap: () {
                              context.push('/devices/${d.id}', extra: d);
                            },
                            child: ListTile(
                              leading: const Icon(Icons.computer, color: MyColors.primary_qcyber),
                              title: Text(d.nome, style: const TextStyle(color: MyColors.textPrimary_qcyber, fontWeight: FontWeight.bold)),
                              subtitle: Text("${d.host} - ${d.localizacao ?? 'N/A'}", style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(d.status.toString(), style: TextStyle(color: d.status == 'Active' ? MyColors.success_qcyber : MyColors.error_qcyber)),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20, color: MyColors.textSecondary_qcyber),
                                    onPressed: () => _showDeviceDialog(dispositivo: d),
                                    tooltip: 'Edit Device',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 50.0,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [ MyColors.background_qcyber.withOpacity(0.0), MyColors.background_qcyber, ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeviceDialog(),
        tooltip: 'Add Device',
        backgroundColor: MyColors.primary_qcyber,
        child: const Icon(Icons.add, color: MyColors.textOnPrimary_qcyber),
      ),
    );
  }
}