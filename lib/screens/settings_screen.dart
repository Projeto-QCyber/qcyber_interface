// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final _formKey = GlobalKey<FormState>();

  bool _isPageLoading = true;
  bool _isSaving = false;
  Map<String, String>? _settingsData;
  String? _error;

  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _senderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _senderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final settings = await _settingsService.getSettings();
      if (mounted) {
        setState(() {
          _settingsData = settings;
          _populateControllers(_settingsData!);
          _isPageLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load settings.";
          _isPageLoading = false;
        });
      }
    }
  }

  void _populateControllers(Map<String, String> settings) {
    _serverController.text = settings['SMTP_SERVER'] ?? '';
    _portController.text = settings['SMTP_PORT'] ?? '';
    _userController.text = settings['SMTP_USER'] ?? '';
    _passwordController.text = settings['SMTP_PASSWORD'] ?? '';
    _senderNameController.text = settings['SMTP_SENDER_NAME'] ?? '';
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final newSettings = {
      'SMTP_SERVER': _serverController.text,
      'SMTP_PORT': _portController.text,
      'SMTP_USER': _userController.text,
      'SMTP_PASSWORD': _passwordController.text,
      'SMTP_SENDER_NAME': _senderNameController.text,
    };

    try {
      final success = await _settingsService.updateSettings(newSettings);

      if (mounted) {
        if (success) {
          setState(() {
            _settingsData = newSettings;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Settings saved successfully!'),
            backgroundColor: MyColors.success_qcyber,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Failed to save settings.'),
            backgroundColor: MyColors.error_qcyber,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: MyColors.error_qcyber,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
    filled: true,
    fillColor: MyColors.background_qcyber,
    border: const UnderlineInputBorder(borderSide: BorderSide(color: MyColors.border_qcyber)),
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primary_qcyber, width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Config.logoBranca, width: 100),
          ),
        ],
      ),
      backgroundColor: MyColors.background_qcyber,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: MyColors.error_qcyber)));
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: MyColors.card_qcyber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: MyColors.border_qcyber),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Email Settings (SMTP)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber),
                      ),
                      const Divider(height: 24, color: MyColors.border_qcyber),
                      TextFormField(controller: _serverController, decoration: _inputDecoration('SMTP Server'), style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                      const SizedBox(height: 16),
                      TextFormField(controller: _portController, decoration: _inputDecoration('SMTP Port'), keyboardType: TextInputType.number, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                      const SizedBox(height: 16),
                      TextFormField(controller: _userController, decoration: _inputDecoration('User (Email)'), style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                      const SizedBox(height: 16),
                      TextFormField(controller: _passwordController, decoration: _inputDecoration('App Password'), obscureText: true, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                      const SizedBox(height: 16),
                      TextFormField(controller: _senderNameController, decoration: _inputDecoration('Sender Name'), style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                      const SizedBox(height: 32),

                      if (_isSaving)
                        const Center(child: CircularProgressIndicator())
                      else
                        Row(
                          children: [
                            // Botão Cancelar (NOVO)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.pop(), // GoRouter pop
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: MyColors.textSecondary_qcyber),
                                ),
                                child: const Text("Cancel", style: TextStyle(color: MyColors.textSecondary_qcyber)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botão Salvar
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save Changes'),
                                onPressed: _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: MyColors.primary_qcyber,
                                  foregroundColor: MyColors.textOnPrimary_qcyber,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}